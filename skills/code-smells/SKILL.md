---
name: code-smells
description: >
  Apply a fixed baseline of Fowler code smells (Refactoring, ch. 3) — Mysterious Name,
  Duplicated Code, Feature Envy, Data Clumps, Primitive Obsession, Repeated Switches,
  Shotgun Surgery, Divergent Change, Speculative Generality, Message Chains, Middle Man,
  Refused Bequest — as a design-quality lens on a diff, PR, or file under review. Each hit
  is a named judgement call with a concrete fix direction, never a hard violation. Use
  alongside any code or PR review (bug-hunting finds what's broken; this names what's
  poorly shaped), or when the user says "code smells", "smell check", asks whether the
  structure or naming is right, or wants refactoring suggestions grounded in a shared
  vocabulary. Repo-documented standards override the baseline; skip anything tooling
  already enforces.
---

# Code smells

A fixed set of Fowler code smells (_Refactoring_, ch. 3) to match against code under
review. It gives findings a shared name and a fix direction — "possible Feature Envy,
move the method onto the data it reaches into" beats "this method feels off".

Adapted from [mattpocock/skills](https://github.com/mattpocock/skills) (code-review
skill), which distilled the baseline from Fowler.

## Rules

Three rules bind every finding:

- **The repo overrides.** A documented repo standard (CODING_STANDARDS.md,
  CONTRIBUTING.md, CLAUDE.md, lint config) always wins. Where the repo endorses
  something the baseline would flag, suppress the smell.
- **Always a judgement call.** Report each hit as a labelled heuristic — "possible
  Feature Envy" — never a hard violation. A smell is a reason to look, not a verdict.
- **Skip what tooling enforces.** If a linter, formatter, or type checker already
  catches it, don't report it.

Scope findings to the code actually under review — don't sweep the whole repo for
smells in code the change didn't touch (mention drive-by observations at most once,
clearly marked as out of scope).

## The baseline

Each smell reads *what it is* → *how to fix*. Match against the diff or file:

- **Mysterious Name** — a function, variable, or type whose name doesn't reveal what it
  does or holds. → rename it; if no honest name comes, the design's murky.
- **Duplicated Code** — the same logic shape appears in more than one hunk or file in
  the change. → extract the shared shape, call it from both.
- **Feature Envy** — a method that reaches into another object's data more than its
  own. → move the method onto the data it envies.
- **Data Clumps** — the same few fields or params keep travelling together (a type
  wanting to be born). → bundle them into one type, pass that.
- **Primitive Obsession** — a primitive or string standing in for a domain concept that
  deserves its own type. → give the concept its own small type.
- **Repeated Switches** — the same `switch`/`if`-cascade on the same type recurs across
  the change. → replace with polymorphism, or one map both sites share.
- **Shotgun Surgery** — one logical change forces scattered edits across many files in
  the diff. → gather what changes together into one module.
- **Divergent Change** — one file or module is edited for several unrelated reasons.
  → split so each module changes for one reason.
- **Speculative Generality** — abstraction, parameters, or hooks added for needs the
  requirements don't have. → delete it; inline back until a real need shows.
- **Message Chains** — long `a.b().c().d()` navigation the caller shouldn't depend on.
  → hide the walk behind one method on the first object.
- **Middle Man** — a class or function that mostly just delegates onward. → cut it,
  call the real target direct.
- **Refused Bequest** — a subclass or implementer that ignores or overrides most of
  what it inherits. → drop the inheritance, use composition.

## Reporting

Per finding: the smell's name, the file/hunk (quote the relevant lines), and the fix
direction from the baseline, adapted to the concrete case. Group by file. If nothing
matches, say so in one line — don't manufacture findings to justify the pass.

When running inside a broader review (e.g. a bug-hunting pass), keep smell findings in
their own section so design-quality judgement calls never mix with correctness bugs —
one axis must not mask the other.
