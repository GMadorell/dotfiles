---
name: checkpoint
description: Use when the user wants to save current session state to disk for resuming in a later session.
---

1. Ask user for optional slug (short kebab-case name for this checkpoint). Default: `session`.

2. Resolve project root: `git rev-parse --show-toplevel` (fallback: cwd).

3. `mkdir -p <project-root>/.claude/checkpoints/`. If `<project-root>/.gitignore` exists and doesn't already ignore `.claude/checkpoints/`, add it.

4. Write `<project-root>/.claude/checkpoints/<YYYYMMDD-HHMM>-<slug>.md` (Write tool) with only the sections that have real content — omit empty ones:

   - **Goal** — what this session is working toward
   - **Progress** — what got done/decided/discovered
   - **In-flight** — what's incomplete
   - **Next steps** — ordered, concrete
   - **Relevant paths** — files/refs needed to resume
   - **Decisions** — choices made and why (only if not obvious from a diff/commit)

   Rules: bullets/fragments, not prose. Don't restate what's recoverable from code, git log, or diffs — capture only what isn't. Target ~1 screen; if it's growing longer, cut.

5. Output the file path and a 1-line TL;DR. Resuming later is manual: user pastes the path into the next session.
