#!/usr/bin/env python3
"""Golden-file test for clean_vtt.py. Run directly: python test_clean_vtt.py"""
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))

from clean_vtt import clean_vtt  # noqa: E402


def main() -> int:
    content = (HERE / "sample.vtt").read_text(encoding="utf-8")
    expected = (HERE / "expected.txt").read_text(encoding="utf-8").rstrip("\n")
    actual = clean_vtt(content)

    if actual != expected:
        print("FAIL: output differs from tests/expected.txt\n", file=sys.stderr)
        print("--- expected ---", file=sys.stderr)
        print(expected, file=sys.stderr)
        print("--- actual ---", file=sys.stderr)
        print(actual, file=sys.stderr)
        return 1

    print("OK: clean_vtt output matches golden file.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
