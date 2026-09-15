---
name: parallel-develop
description: Set up development for one or more issues using git worktrees and tmux with Claude Code, Codex, Pi, OpenCode, or Gemini CLI.
argument-hint: <issue-numbers...> [--agent claude|codex|pi|opencode|gemini] [--model <model>]
---

# Parallel Develop

Spawn coding-agent workers to solve GitHub issues in isolated worktrees.

## Step 1: Validate Issues

- Verify at least 1 issue number is provided
- Run `gh issue view <number>` for each to confirm they exist
- When using multiple issues, only parallelize issues that are truly independent — if issue B depends on issue A's output, run B after A, not in parallel
- Recommend maximum 4-6 issues for tmux usability

## Step 2: Spawn Workers

- Use the agent requested by the user; otherwise match the coordinating agent when known, falling back to `claude` when unknown. Supported agents: `claude`, `codex`, `pi`, `opencode`, and `gemini`.
- Always pass the selected agent explicitly. The script defaults to `claude` for existing callers that omit `--agent`.
- Use an explicitly requested model. Otherwise reuse the coordinator's model only when known and using the same agent; omit `--model` to use the worker's configured default. Model identifiers are passed unchanged (OpenCode expects `provider/model`).
- Check that `tmux` and the selected agent executable are available before creating worktrees.
- Resolve `<skill-directory>` to the absolute directory containing this `SKILL.md`. For a Claude plugin installation, it is `${CLAUDE_PLUGIN_ROOT}/skills/parallel-develop`; for other installations, use the loaded skill location.

For each issue:

1. Create worktree and branch:
   ```bash
   git worktree add ../<repo-name>-<issue> -b <git-user>/feature-<issue>
   ```

2. Launch a worker pane. The second argument is the initial task message. The launcher instructs every worker to follow repository guidance, present a plan, and await approval before implementing:

   ```bash
   "<skill-directory>/scripts/spawn-worker.sh" "../<repo-name>-<issue>" "Investigate GitHub issue #<issue> and propose an implementation plan." --agent <selected-agent>
   ```

   Include extra context in the message and add `--model` when selecting a model:

   ```bash
   "<skill-directory>/scripts/spawn-worker.sh" "../<repo-name>-<issue>" "Focus on the API layer only. Investigate GitHub issue #<issue> and propose an implementation plan." --agent <selected-agent> --model <selected-model>
   ```

After all workers are spawned:
```bash
tmux select-layout main-horizontal
```

## Step 3: Output Summary

Provide:
- List of worktrees with full paths and the selected worker agents
- Pane navigation: `Ctrl+b + arrow keys`
- Cleanup commands (run in this order):
  ```bash
  tmux kill-pane -t <pane-id>
  git worktree remove ../<repo-name>-<issue>
  git branch -d <git-user>/feature-<issue>
  ```

## Notes

- Workers present a plan for approval before implementing. Claude Code uses `--permission-mode plan`, OpenCode uses `--agent plan`, and Gemini CLI uses `--approval-mode plan`. Codex and Pi receive prompt-based planning instructions; these do not add a sandbox restriction.
- Workers remain interactive. Handle startup or trust prompts in the worker pane.
- Switch to a worker pane with `Ctrl+b + arrow keys` to intervene if needed
- If a pane gets stuck, use `Ctrl+c` to interrupt
- Resolve `<git-user>` with `git config user.name | tr ' ' '-' | tr '[:upper:]' '[:lower:]'`
- Resolve `<repo-name>` from `git remote get-url origin`
