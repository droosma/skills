---
name: simplify
description: >
  Review recently changed code for clarity, consistency, and maintainability
  without changing behavior. Use when the user says "simplify", asks to clean
  up a diff, reduce complexity or redundancy in changed code, improve names in
  recent edits, review staged changes, or simplify files relative to a branch.
---

# Simplify changed code

Improve the code in the requested diff while preserving its behavior.

## Choose the change set

Use the scope named by the user:

- staged changes: compare the index with `HEAD`
- named files: inspect only those files
- named reference: compare the working tree with that branch or commit
- no explicit scope: inspect all staged and unstaged changes

Include newly added files in full. For existing files, identify the changed
line ranges and keep edits within those ranges. Read surrounding code only for
context.

## Review each changed file

Work through one file at a time:

1. Read the repository instructions and nearby code.
2. Find avoidable complexity, duplication, indirect control flow, and unclear
   names in the changed lines.
3. Apply the smallest edits that improve clarity and consistency.
4. Preserve public behavior, error handling, validation, security, and
   accessibility.
5. Run the smallest existing test, build, or lint command that covers the
   edited behavior.

Do not rewrite unchanged areas, introduce speculative abstractions, or reduce
code merely to lower the line count.

## Report

Summarize the meaningful simplifications and state whether behavior changed.
