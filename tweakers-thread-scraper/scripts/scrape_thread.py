#!/usr/bin/env python3
"""Scrape a complete Tweakers (Gathering of Tweakers) forum thread.

Walks every page of a `list_messages` topic and extracts, per post:
  - message id, poster (+ id), date/time (ISO + unix timestamp)
  - the post's own text and raw HTML (quote blocks separated out)
  - links included in the post
  - media (images / videos / embeds) included in the post
  - references to any quoted posts (quoted message id, poster, date, text)

Outputs a JSON file by default, and optionally a SQLite database (with an
FTS5 full-text index) that is convenient for cross-thread research search.

Usage:
    python scrape_thread.py <url-or-topic-id> [options]

    # full URL or bare topic id both work
    python scrape_thread.py https://gathering.tweakers.net/forum/list_messages/2074350/
    python scrape_thread.py 2074350 --sqlite

Options:
    --out FILE        JSON output path (default: thread_<id>.json next to cwd)
    --sqlite [FILE]   also build a SQLite db (default: thread_<id>.db)
    --delay SEC       polite delay between page requests (default: 1.0)
    --max-pages N     stop after N pages (default: all)
    --no-html         do not store raw post HTML (smaller output)
"""
from __future__ import annotations

import argparse
import json
import re
import sqlite3
import sys
import time
from datetime import datetime, timezone

import requests
from bs4 import BeautifulSoup

BASE = "https://gathering.tweakers.net/forum/list_messages/{id}"
HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
        "(KHTML, like Gecko) Chrome/120.0 Safari/537.36"
    ),
    "Accept-Language": "nl-NL,nl;q=0.9,en;q=0.8",
}
MSG_RE = re.compile(r"/list_message[s]?/(\d+)")


def topic_id_from_arg(arg: str) -> int:
    m = re.search(r"list_messages/(\d+)", arg)
    if m:
        return int(m.group(1))
    if arg.strip().isdigit():
        return int(arg.strip())
    raise SystemExit(f"Could not work out a topic id from: {arg!r}")


def fetch(session: requests.Session, url: str) -> str:
    resp = session.get(url, headers=HEADERS, timeout=30)
    resp.raise_for_status()
    resp.encoding = resp.apparent_encoding or "utf-8"
    return resp.text


def discover_pages(soup: BeautifulSoup, topic_id: int) -> int:
    """Total number of pages. Base URL is page 1; /N in the url is page N+1."""
    indices = [0]
    dist = soup.select_one(".pageDistribution") or soup
    for a in dist.find_all("a", href=True):
        m = re.search(rf"/list_messages/{topic_id}/(\d+)", a["href"])
        if m:
            indices.append(int(m.group(1)))
    return max(indices) + 1


def page_url(topic_id: int, page_index: int) -> str:
    base = BASE.format(id=topic_id)
    return base if page_index == 0 else f"{base}/{page_index}"


def brs_to_newlines(node) -> None:
    for br in node.find_all("br"):
        br.replace_with("\n")


def clean_text(node) -> str:
    text = node.get_text()
    # collapse runs of blank lines / trailing whitespace
    lines = [ln.rstrip() for ln in text.splitlines()]
    out, blanks = [], 0
    for ln in lines:
        if ln.strip() == "":
            blanks += 1
            if blanks <= 1:
                out.append("")
        else:
            blanks = 0
            out.append(ln)
    return "\n".join(out).strip()


def parse_quote(qdiv) -> dict:
    """A <div class=message-quote-div> header + quoted body."""
    quote = {
        "quoted_message_id": None,
        "quoted_poster": None,
        "quoted_datetime_text": None,
        "text": None,
    }
    link = qdiv.find("a", class_="messagelink", href=True)
    if link:
        m = MSG_RE.search(link["href"])
        if m:
            quote["quoted_message_id"] = int(m.group(1))
        label = link.get_text(" ", strip=True)
        # "Poster schreef op woensdag 16 juni 2021 @ 00:32"
        parts = re.split(r"\s+schreef op\s+", label, maxsplit=1)
        quote["quoted_poster"] = parts[0].strip() or None
        if len(parts) > 1:
            quote["quoted_datetime_text"] = parts[1].strip().rstrip(":")
    # quoted body = the div text minus the header line (the <b> block)
    body = BeautifulSoup(str(qdiv), "lxml")
    header_b = body.find("b")
    if header_b:
        header_b.decompose()
    inner = body.find("div", class_="message-quote-div")
    if inner:
        brs_to_newlines(inner)
        quote["text"] = clean_text(inner) or None
    return quote


def absolute(url: str) -> str:
    if url.startswith("//"):
        return "https:" + url
    return url


def parse_media(content) -> list[dict]:
    media = []
    seen = set()
    for img in content.find_all("img"):
        src = img.get("src")
        if not src:
            continue
        src = absolute(src)
        full = None
        parent_a = img.find_parent("a", href=True)
        if parent_a and "imageviewer" in (parent_a.get("rel") or []):
            full = absolute(parent_a["href"])
        key = (src, full)
        if key in seen:
            continue
        seen.add(key)
        media.append({"type": "image", "src": src, "full_url": full})
    for vid in content.find_all("video"):
        src = vid.get("src") or (vid.find("source") and vid.find("source").get("src"))
        if src:
            media.append({"type": "video", "src": absolute(src), "full_url": None})
    for iframe in content.find_all("iframe"):
        src = iframe.get("src")
        if src:
            media.append({"type": "embed", "src": absolute(src), "full_url": None})
    return media


def parse_links(content) -> list[dict]:
    links = []
    seen = set()
    for a in content.find_all("a", href=True):
        href = a["href"].strip()
        if href.startswith(("javascript:", "#")):
            continue
        # skip image-viewer wrappers — those are captured as media instead
        if "imageviewer" in (a.get("rel") or []) and a.find("img"):
            continue
        href = absolute(href)
        text = a.get_text(" ", strip=True)
        if href in seen:
            continue
        seen.add(href)
        links.append({"url": href, "text": text})
    return links


def parse_datetime(header) -> tuple[str | None, int | None]:
    span = header.select_one("span[data-timestamp]")
    if not span:
        return None, None
    ts = span.get("data-timestamp")
    iso = None
    dt_attr = span.get("data-datetime")  # "01-06-2021 21:27"
    if dt_attr:
        try:
            iso = datetime.strptime(dt_attr, "%d-%m-%Y %H:%M").isoformat()
        except ValueError:
            iso = None
    if iso is None and ts:
        iso = datetime.fromtimestamp(int(ts), tz=timezone.utc).isoformat()
    return iso, (int(ts) if ts else None)


def parse_post(div, topic_id: int, page: int, position: int, keep_html: bool) -> dict:
    message_id = int(div["data-message-id"])
    owner_id = div.get("data-owner-id")
    classes = div.get("class") or []

    header = div.select_one(".messageheader")
    iso, ts = parse_datetime(header) if header else (None, None)

    poster_el = div.select_one(".userheader .username a.user") or div.select_one(
        ".poster .username .user"
    )
    poster = poster_el.get_text(strip=True) if poster_el else None

    content = div.select_one(".messagecontent")
    content_html = content.decode_contents().strip() if (content and keep_html) else None

    quotes, links, media, text = [], [], [], None
    if content:
        # work on a copy so we can strip quotes for the post's own text/links/media
        work = BeautifulSoup(str(content), "lxml")
        for qdiv in work.find_all("div", class_="message-quote-div"):
            quotes.append(parse_quote(qdiv))
        for bq in work.find_all("blockquote"):
            bq.decompose()
        body = work.find(class_="messagecontent") or work
        links = parse_links(body)
        media = parse_media(body)
        brs_to_newlines(body)
        text = clean_text(body)

    return {
        "message_id": message_id,
        "poster_id": int(owner_id) if owner_id and owner_id.isdigit() else owner_id,
        "poster": poster,
        "is_topicstarter": "topicstarter" in classes,
        "datetime": iso,
        "timestamp": ts,
        "page": page,
        "position": position,
        "url": f"https://gathering.tweakers.net/forum/list_message/{message_id}#{message_id}",
        "text": text,
        "content_html": content_html,
        "links": links,
        "media": media,
        "quotes": quotes,
    }


def scrape(topic_id: int, delay: float, max_pages: int | None, keep_html: bool) -> dict:
    session = requests.Session()
    first_html = fetch(session, page_url(topic_id, 0))
    soup = BeautifulSoup(first_html, "lxml")

    title_el = soup.select_one("h1")
    title = title_el.get_text(strip=True) if title_el else None
    total_pages = discover_pages(soup, topic_id)
    if max_pages:
        total_pages = min(total_pages, max_pages)

    posts = []
    position = 0
    for page_index in range(total_pages):
        page_no = page_index + 1
        html = first_html if page_index == 0 else fetch(session, page_url(topic_id, page_index))
        psoup = BeautifulSoup(html, "lxml")
        divs = psoup.find_all("div", attrs={"data-message-id": True})
        print(f"  page {page_no}/{total_pages}: {len(divs)} posts", file=sys.stderr)
        for div in divs:
            if not div.has_attr("class") or "message" not in div["class"]:
                continue
            posts.append(parse_post(div, topic_id, page_no, position, keep_html))
            position += 1
        if page_index != total_pages - 1:
            time.sleep(delay)

    return {
        "topic": {
            "id": topic_id,
            "title": title,
            "url": BASE.format(id=topic_id),
            "pages": total_pages,
            "post_count": len(posts),
            "scraped_at": datetime.now(timezone.utc).isoformat(),
        },
        "posts": posts,
    }


def build_sqlite(data: dict, db_path: str) -> None:
    con = sqlite3.connect(db_path)
    cur = con.cursor()
    cur.executescript(
        """
        DROP TABLE IF EXISTS topic;
        DROP TABLE IF EXISTS posts;
        DROP TABLE IF EXISTS links;
        DROP TABLE IF EXISTS media;
        DROP TABLE IF EXISTS quotes;
        DROP TABLE IF EXISTS posts_fts;

        CREATE TABLE topic (id INTEGER PRIMARY KEY, title TEXT, url TEXT,
                            pages INTEGER, post_count INTEGER, scraped_at TEXT);
        CREATE TABLE posts (
            message_id INTEGER PRIMARY KEY, topic_id INTEGER, page INTEGER,
            position INTEGER, is_topicstarter INTEGER, poster TEXT, poster_id INTEGER,
            datetime TEXT, timestamp INTEGER, url TEXT, text TEXT, content_html TEXT);
        CREATE TABLE links (message_id INTEGER, url TEXT, text TEXT);
        CREATE TABLE media (message_id INTEGER, type TEXT, src TEXT, full_url TEXT);
        CREATE TABLE quotes (message_id INTEGER, quoted_message_id INTEGER,
            quoted_poster TEXT, quoted_datetime_text TEXT, text TEXT);
        CREATE VIRTUAL TABLE posts_fts USING fts5(
            poster, text, tokenize='unicode61');
        """
    )
    t = data["topic"]
    cur.execute(
        "INSERT INTO topic VALUES (?,?,?,?,?,?)",
        (t["id"], t["title"], t["url"], t["pages"], t["post_count"], t["scraped_at"]),
    )
    for p in data["posts"]:
        cur.execute(
            "INSERT INTO posts VALUES (?,?,?,?,?,?,?,?,?,?,?,?)",
            (
                p["message_id"], t["id"], p["page"], p["position"],
                int(p["is_topicstarter"]), p["poster"],
                p["poster_id"] if isinstance(p["poster_id"], int) else None,
                p["datetime"], p["timestamp"], p["url"], p["text"], p["content_html"],
            ),
        )
        cur.execute(
            "INSERT INTO posts_fts (rowid, poster, text) VALUES (?,?,?)",
            (p["message_id"], p["poster"] or "", p["text"] or ""),
        )
        for l in p["links"]:
            cur.execute("INSERT INTO links VALUES (?,?,?)", (p["message_id"], l["url"], l["text"]))
        for md in p["media"]:
            cur.execute(
                "INSERT INTO media VALUES (?,?,?,?)",
                (p["message_id"], md["type"], md["src"], md["full_url"]),
            )
        for q in p["quotes"]:
            cur.execute(
                "INSERT INTO quotes VALUES (?,?,?,?,?)",
                (p["message_id"], q["quoted_message_id"], q["quoted_poster"],
                 q["quoted_datetime_text"], q["text"]),
            )
    con.commit()
    con.close()


def main() -> None:
    ap = argparse.ArgumentParser(description="Scrape a Tweakers forum thread.")
    ap.add_argument("target", help="thread URL or bare topic id")
    ap.add_argument("--out", help="JSON output path")
    ap.add_argument("--sqlite", nargs="?", const="__default__",
                    help="also build a SQLite db (optional path)")
    ap.add_argument("--delay", type=float, default=1.0, help="delay between pages (s)")
    ap.add_argument("--max-pages", type=int, default=None)
    ap.add_argument("--no-html", action="store_true", help="omit raw post HTML")
    args = ap.parse_args()

    topic_id = topic_id_from_arg(args.target)
    print(f"Scraping topic {topic_id} ...", file=sys.stderr)
    data = scrape(topic_id, args.delay, args.max_pages, keep_html=not args.no_html)

    out = args.out or f"thread_{topic_id}.json"
    with open(out, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"Wrote {len(data['posts'])} posts -> {out}", file=sys.stderr)

    if args.sqlite:
        db = args.sqlite if args.sqlite != "__default__" else f"thread_{topic_id}.db"
        build_sqlite(data, db)
        print(f"Wrote SQLite db -> {db}", file=sys.stderr)


if __name__ == "__main__":
    main()
