# Long-running work

Before you start any multi-phase or long-running task, write a PROGRESS.md
checklist of every phase. After completing each phase, update PROGRESS.md and
save all outputs to the project directory so we can resume if interrupted.

Break work into small phases, persist state *before* each phase, and verify
artifacts exist on disk before marking a phase done. (Claude Code sessions:
the `checkpoint` skill defines the full format.)
