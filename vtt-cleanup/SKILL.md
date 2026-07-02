---
name: vtt-cleanup
description: >
  Strip metadata noise from WebVTT (.vtt) transcript files to produce clean, readable text
  suitable for LLM consumption. Removes UUIDs/hashes, detailed timestamps, VTT markup tags,
  and blank lines — leaving only speaker names and their spoken text. Use when the user has
  a .vtt file (e.g., from Microsoft Teams) and wants a clean transcript, or mentions
  "clean up vtt", "strip vtt", "vtt to text", "transcript cleanup", or "prepare transcript for LLM".

---

# VTT Cleanup

Converts verbose WebVTT transcript files (e.g., from Microsoft Teams meetings) into clean,
LLM-friendly plain text by stripping all metadata noise.

## What gets removed

- The `WEBVTT` header
- Cue identifiers (UUIDs/hashes like `0166bfd0-b4a9-4b0f-b958-4e70de488612/32-0`)
- Timestamp lines (`00:03:56.355 --> 00:03:59.475`)
- VTT voice tags (`<v Speaker Name>...</v>`) — replaced with `Speaker Name:` prefix
- Consecutive duplicate lines from the same speaker (merged)
- Excess blank lines

## Output format

```
Speaker Name: Spoken text here.
Speaker Name: Their response.
```

## Usage

Run `clean_vtt.py` — it lives next to this SKILL.md, so resolve it relative to this skill's directory:

```
python <skill-dir>/clean_vtt.py "path/to/file.vtt"
```

This outputs the cleaned transcript to stdout. Use the `--output` flag to write a file instead:

```
python <skill-dir>/clean_vtt.py "path/to/file.vtt" --output cleaned.txt
```

## Instructions for the agent

When the user provides a .vtt file or asks to clean a transcript:

1. Run the `clean_vtt.py` script on the input file
2. Save the output to a `.txt` file next to the original (or where the user specifies)
3. Report the line count reduction and output location
