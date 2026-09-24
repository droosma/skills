---
name: tweakers-thread-scraper
description: Scrape a complete Tweakers (Gathering of Tweakers, gathering.tweakers.net) forum thread across all its pages into a structured JSON file and/or a searchable SQLite database. For each post it captures the content, date/time, poster, included links, included media, and references to quoted posts. Use when the user wants to archive, extract, mine, or research a Tweakers forum topic/thread, or gives a gathering.tweakers.net/forum/list_messages URL and wants its contents as data.
---

# Tweakers thread scraper

Extracts an entire Tweakers GoT forum thread into structured data for research.

## When to use

The user supplies a Tweakers thread URL (e.g.
`https://gathering.tweakers.net/forum/list_messages/2074350/`) or a topic id, and
wants the posts as data they can search or analyse across topics.

## Running it

The script is `scripts/scrape_thread.py` **inside this skill's directory** (the directory containing this SKILL.md) — the working directory at invocation time is the user's project, so resolve the path first:

```bash
python <skill-dir>/scripts/scrape_thread.py <url-or-topic-id> [options]
```

A full URL or a bare topic id both work. Examples:

```bash
# JSON only
python <skill-dir>/scripts/scrape_thread.py https://gathering.tweakers.net/forum/list_messages/2074350/

# JSON + searchable SQLite db (recommended for research)
python <skill-dir>/scripts/scrape_thread.py 2074350 --sqlite
```

Options:
- `--out FILE` — JSON output path (default `thread_<id>.json` in the cwd).
- `--sqlite [FILE]` — also build a SQLite db (default `thread_<id>.db`).
- `--delay SEC` — delay between page requests (default `1.0`; be polite).
- `--max-pages N` — only scrape the first N pages (useful for a quick test).
- `--no-html` — omit the raw post HTML to shrink the output.

Requires Python 3 with `requests`, `beautifulsoup4`, and `lxml`. Check before
the first run (`python -c "import requests, bs4, lxml"`) and `pip install` any
that are missing. Write outputs to the user's chosen location or the current
project directory, never inside the skill directory.

## Output: JSON shape

```jsonc
{
  "topic": { "id", "title", "url", "pages", "post_count", "scraped_at" },
  "posts": [
    {
      "message_id": 67538078,
      "poster": "kroonen", "poster_id": 269738,
      "is_topicstarter": true,
      "datetime": "2021-06-01T21:27:00",   // local thread time, ISO
      "timestamp": 1622575671,             // unix
      "page": 1, "position": 0,
      "url": "https://gathering.tweakers.net/forum/list_message/67538078#67538078",
      "text": "post's own text, with quote blocks removed",
      "content_html": "raw inner HTML of the post (null with --no-html)",
      "links":  [ { "url", "text" } ],
      "media":  [ { "type": "image|video|embed", "src", "full_url" } ],
      "quotes": [ { "quoted_message_id", "quoted_poster",
                    "quoted_datetime_text", "text" } ]
    }
  ]
}
```

Notes:
- `text` is the poster's own words; quoted material lives in `quotes`, not `text`.
- `media` images give the inline `src` plus the full-resolution `full_url` when available.
- `quotes[].quoted_message_id` links a reply back to the post it quotes (which is
  usually elsewhere in the same JSON/db), enabling conversation-thread reconstruction.

## Output: SQLite (best for searching)

`--sqlite` builds tables `topic`, `posts`, `links`, `media`, `quotes`, plus an
FTS5 full-text index `posts_fts` (columns `poster`, `text`, with `rowid =
message_id`).

Search examples:

```sql
-- full-text search with highlighted snippets
SELECT p.poster, p.datetime,
       snippet(posts_fts, 1, '>>', '<<', '...', 12) AS hit
FROM posts_fts JOIN posts p ON p.message_id = posts_fts.rowid
WHERE posts_fts MATCH 'homeassistant OR domoticz';

-- every external link shared in the thread
SELECT message_id, url FROM links WHERE url NOT LIKE '%tweakers.net%';

-- reconstruct who replied to whom
SELECT q.message_id AS reply, q.quoted_poster, q.quoted_message_id AS quoted
FROM quotes q;
```

## How it works (for adapting)

- Pages: the base `list_messages/<id>` URL is page 1; `/<n>` is page n+1. The
  script reads the `.pageDistribution` block to find the last page.
- Posts: `div[data-message-id]` carries the id and `data-owner-id`; date/time
  comes from `span[data-timestamp]`; the body is `.messagecontent`; quotes are
  `blockquote > div.message-quote-div`.
- If Tweakers changes its markup, these selectors in `scripts/scrape_thread.py`
  are where to adjust.
