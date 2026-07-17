# Coding guidelines

Adapted from Andrej Karpathy's observations on LLM coding pitfalls
(via [andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills), MIT).
These bias toward caution over speed — for trivial tasks, use judgment.

## Surgical changes

Touch only what you must; every changed line should trace directly to the request.

- Don't "improve" adjacent code, comments, or formatting. Match existing style,
  even if you'd do it differently.
- Don't refactor things that aren't broken. If you notice unrelated dead code
  or problems, mention them — don't fix them unprompted.
- Do remove imports/variables/functions that *your* change made unused; leave
  pre-existing dead code alone.

## Simplicity first

Minimum code that solves the problem; nothing speculative.

- No features beyond what was asked, no abstractions for single-use code, no
  unrequested "flexibility" or "configurability", no error handling for
  impossible scenarios.
- Ask: "would a senior engineer call this overcomplicated?" If yes, simplify.

## Verifiable goals

Transform vague tasks into verifiable ones before starting:

- "Fix the bug" → "write a test that reproduces it, then make it pass."
- "Add validation" → "write tests for invalid inputs, then make them pass."
- "Refactor X" → "ensure tests pass before and after."

For multi-step work, state a brief plan with a verify step per item.
