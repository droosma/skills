#!/usr/bin/env python3
"""Parser test against a saved fixture of the Tweakers markup.

Run directly: python test_parse.py
If Tweakers changes its markup, update the selectors in scrape_thread.py AND
this fixture together — the fixture documents the markup the parser expects.
"""
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / "scripts"))

from bs4 import BeautifulSoup  # noqa: E402

from scrape_thread import discover_pages, parse_post  # noqa: E402

TOPIC_ID = 2074350


def main() -> int:
    html = (HERE / "fixture_page.html").read_text(encoding="utf-8")
    soup = BeautifulSoup(html, "lxml")

    assert discover_pages(soup, TOPIC_ID) == 3, "pageDistribution should yield 3 pages"

    divs = [
        d for d in soup.find_all("div", attrs={"data-message-id": True})
        if "message" in (d.get("class") or [])
    ]
    assert len(divs) == 2, f"expected 2 posts, got {len(divs)}"

    first = parse_post(divs[0], TOPIC_ID, page=1, position=0, keep_html=True)
    assert first["message_id"] == 67538078
    assert first["poster"] == "kroonen"
    assert first["poster_id"] == 269738
    assert first["is_topicstarter"] is True
    assert first["datetime"] == "2021-06-01T21:27:00"
    assert first["timestamp"] == 1622575620
    assert "Welkom in het nieuwe topic!" in first["text"]
    assert first["links"] == [
        {"url": "https://www.home-assistant.io/", "text": "Home Assistant"}
    ], "imageviewer wrapper must land in media, not links"
    assert first["media"] == [{
        "type": "image",
        "src": "https://tweakers.net/ext/f/abc123/thumb.jpg",
        "full_url": "https://tweakers.net/ext/f/abc123/full.jpg",
    }]
    assert first["quotes"] == []
    assert first["content_html"]

    second = parse_post(divs[1], TOPIC_ID, page=1, position=1, keep_html=False)
    assert second["message_id"] == 67538190
    assert second["poster"] == "reply_guy"
    assert second["is_topicstarter"] is False
    assert second["content_html"] is None
    assert "Zigbee2MQTT" in second["text"]
    assert "Welkom" not in second["text"], "quoted text must not leak into the post's own text"
    assert len(second["quotes"]) == 1
    quote = second["quotes"][0]
    assert quote["quoted_message_id"] == 67538078
    assert quote["quoted_poster"] == "kroonen"
    assert "Welkom in het nieuwe topic!" in (quote["text"] or "")

    print("OK: fixture parses into the documented JSON shape.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
