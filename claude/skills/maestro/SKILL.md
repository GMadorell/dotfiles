---
name: maestro
description: Use when the user wants a nontrivial task planned, architected, or designed and saved as a doc rather than answered inline.
---

1. Run the `maestro` agent (subagent_type: `maestro`) via the Agent tool, in the foreground (`run_in_background: false`), with `model: "opus"` explicitly set (the environment may default subagents to a cheaper model — override it).

   The subagent starts with no memory of this conversation, so the prompt must be self-contained:
   - absolute cwd (`pwd`)
   - the task to plan, verbatim from the user/arguments
   - any constraints already discussed in this conversation worth passing along

   Do not pre-research the task yourself — that's the agent's job and doing it twice wastes context. Just launch it and wait.

2. When it returns, relay only the file path and its short summary to the user. Don't read the plan file into this conversation unless the user asks to see it.

3. Invoke the `crit` skill on the plan file so the user can leave inline review comments.

4. After the user finishes commenting, use `crit-cli` to read the comments and address them yourself with Edit directly on the plan file — no new subagent needed for most feedback, since maestro's research is already captured in the doc. Only re-invoke `maestro` (step 1) if a comment requires genuinely new codebase research the doc doesn't cover.
