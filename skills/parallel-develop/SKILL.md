---
name: parallel-develop
description: Set up parallel development for multiple issues using git worktrees and tmux.
argument-hint: <issue-numbers...>
---

# Parallel Develop

Spawn parallel Claude Code workers to solve multiple GitHub issues simultaneously.

## Step 1: Validate Issues

- Verify at least 2 issue numbers are provided
- Run `gh issue view <number>` for each to confirm they exist
- Only parallelize issues that are truly independent — if issue B depends on issue A's output, run B after A, not in parallel
- Recommend maximum 4-6 issues for tmux usability

## Step 2: Spawn Workers

For each issue:

1. Create worktree and branch:
   ```bash
   git worktree add ../<repo-name>-<issue> -b <git-user>/feature-<issue>
   ```

2. Launch worker pane. The second argument is the initial message sent to the worker's Claude Code session.
   Use the same model as the coordinator:

   ```bash
   ${CLAUDE_PLUGIN_ROOT}/skills/parallel-develop/scripts/spawn-worker.sh "../<repo-name>-<issue>" "Resolve the GitHub issue #<issue>" --model <current-model>
   ```

   To provide extra context, prepend it before the instruction:

   ```bash
   ${CLAUDE_PLUGIN_ROOT}/skills/parallel-develop/scripts/spawn-worker.sh "../<repo-name>-<issue>" "Focus on the API layer only. Resolve the GitHub issue #<issue>" --model <current-model>
   ```

After all workers are spawned:
```bash
tmux select-layout main-vertical
```

## Step 3: Output Summary

Provide:
- List of worktrees with full paths
- Pane navigation: `Ctrl+b + arrow keys`
- Cleanup commands (run in this order):
  ```bash
  tmux kill-pane -t <pane-id>
  git worktree remove ../<repo-name>-<issue>
  git branch -d <git-user>/feature-<issue>
  ```

## Notes

- Workers start in plan mode — they present a plan for approval before implementing
- Switch to a worker pane with `Ctrl+b + arrow keys` to intervene if needed
- If a pane gets stuck, use `Ctrl+c` to interrupt
- Resolve `<git-user>` with `git config user.name | tr ' ' '-' | tr '[:upper:]' '[:lower:]'`
- Resolve `<repo-name>` from `git remote get-url origin`
