# Working agreements

## File & artifact conventions

Save all artifacts, documents, and outputs to the current project directory —
never to a memory/vault or external directory unless explicitly asked.

## Design discussions

Do not conclude with a verdict or decision unless asked — default to
open-ended brainstorming of scenarios and options until the user signals they
want a decision.

## Documentation & reports

Ground all reports, reviews, and design docs in the actual source code or real
usage data before making claims; verify pricing, config, and behavior against
primary sources. A number without a citation is an assumption — label it as one.

## Web scraping / API access

When scraping web pages or hitting external APIs, always include retry/backoff
logic and a conservative inter-request delay to avoid HTTP 429 rate-limiting.
Write results incrementally (JSONL append or per-item db insert) so an
interrupted run loses at most one item.

## PowerShell / shell

Prefer file-based scripts over inline PowerShell here-strings; here-string
escaping (`@` characters) has repeatedly broken scripts and leaked into git
commit messages. Write the script to a file, then execute the file.
