#!/usr/bin/env python3
"""
Clean WebVTT (.vtt) transcript files by stripping metadata noise.

Removes:
- WEBVTT header
- Cue identifiers (UUIDs, hashes)
- Timestamp lines (HH:MM:SS.mmm --> HH:MM:SS.mmm)
- VTT voice tags (<v Name>...</v>)
- Duplicate consecutive lines from the same speaker
- Excess blank lines

Output: clean "Speaker: text" format suitable for LLM consumption.
"""

import re
import sys
import argparse
from pathlib import Path


TIMESTAMP_RE = re.compile(r"^\d{2}:\d{2}:\d{2}\.\d{3}\s*-->\s*\d{2}:\d{2}:\d{2}\.\d{3}")
CUE_ID_RE = re.compile(r"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}", re.IGNORECASE)
VOICE_TAG_RE = re.compile(r"<v\s+([^>]+)>(.*?)</v>", re.DOTALL)
ANY_TAG_RE = re.compile(r"<[^>]+>")


def parse_cue_blocks(content: str) -> list[tuple[str | None, str]]:
    """Parse VTT into a list of (speaker, text) tuples, one per cue block."""
    lines = content.splitlines()
    blocks: list[tuple[str | None, str]] = []

    i = 0
    while i < len(lines):
        stripped = lines[i].strip()

        # Skip header, blank lines, cue IDs, timestamps
        if not stripped or stripped == "WEBVTT" or CUE_ID_RE.match(stripped) or TIMESTAMP_RE.match(stripped):
            i += 1
            continue

        # Collect text lines until next blank line or metadata
        text_lines = []
        while i < len(lines):
            stripped = lines[i].strip()
            if not stripped:
                i += 1
                break
            if CUE_ID_RE.match(stripped) or TIMESTAMP_RE.match(stripped):
                break
            text_lines.append(stripped)
            i += 1

        if not text_lines:
            continue

        # Join multi-line cue text and extract speaker
        full_text = " ".join(text_lines)
        voice_match = VOICE_TAG_RE.search(full_text)
        if voice_match:
            speaker = voice_match.group(1).strip()
            text = voice_match.group(2).strip()
        else:
            text = ANY_TAG_RE.sub("", full_text).strip()
            speaker = None

        if text:
            blocks.append((speaker, text))

    return blocks


def clean_vtt(content: str) -> str:
    blocks = parse_cue_blocks(content)
    output_lines: list[str] = []
    last_speaker = None

    for speaker, text in blocks:
        # Merge consecutive lines from the same speaker
        if speaker == last_speaker and output_lines:
            output_lines[-1] = output_lines[-1] + " " + text
        else:
            prefix = f"{speaker}: " if speaker else ""
            output_lines.append(f"{prefix}{text}")
            last_speaker = speaker

    return "\n".join(output_lines)


def main():
    parser = argparse.ArgumentParser(
        description="Clean WebVTT transcript files for LLM consumption."
    )
    parser.add_argument("input", help="Path to the .vtt file")
    parser.add_argument(
        "--output", "-o",
        help="Output file path (default: stdout)",
        default=None,
    )
    args = parser.parse_args()

    input_path = Path(args.input)
    if not input_path.exists():
        print(f"Error: File not found: {input_path}", file=sys.stderr)
        sys.exit(1)

    # Try common encodings for Teams VTT files
    content = None
    for encoding in ["utf-8-sig", "utf-8", "utf-16", "cp1252"]:
        try:
            content = input_path.read_text(encoding=encoding)
            break
        except (UnicodeDecodeError, UnicodeError):
            continue

    if content is None:
        print(f"Error: Could not decode file: {input_path}", file=sys.stderr)
        sys.exit(1)

    result = clean_vtt(content)

    if args.output:
        output_path = Path(args.output)
        output_path.write_text(result, encoding="utf-8")
        input_lines = len(content.splitlines())
        output_lines = len(result.splitlines())
        print(
            f"Done: {input_lines} lines -> {output_lines} lines "
            f"({100 - (output_lines / max(input_lines, 1) * 100):.0f}% reduction)",
            file=sys.stderr,
        )
    else:
        print(result)


if __name__ == "__main__":
    main()
