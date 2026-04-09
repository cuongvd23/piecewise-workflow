# piecewise-workflow

A [Claude Code](https://docs.anthropic.com/en/docs/claude-code) plugin that breaks large features into small, reviewable pieces.

Built following the [Agent Skills](https://agentskills.io) open standard.

## Install

```bash
npx skills add cuongvd23/piecewise-workflow
```

## Skills

| Skill | What it does |
|-------|-------------|
| `plan-task` | Reads a GitHub issue, explores the codebase, proposes sub-issues with acceptance criteria, gets your approval, then creates and links them via GitHub's sub-issues API |
| `parallel-develop` | Spawns parallel Claude Code workers in tmux panes, one per issue, each in its own git worktree |
| `post-task-verification` | Checks your implementation against the original requirements, searches for orphaned patterns, and flags gaps |
| `commit` | Splits staged changes into multiple logical commits, each doing one thing |

## Usage

Skills are namespaced under `piecewise-workflow`:

```
/piecewise-workflow:plan-task 123
/piecewise-workflow:parallel-develop 201 202 204
/piecewise-workflow:post-task-verification 123
/piecewise-workflow:commit
```

When installed via `npx skills add`, skills are symlinked into `~/.claude/skills/` and can be used directly without the namespace:

```
/plan-task 123
/parallel-develop 201 202 204
/post-task-verification 123
/commit
```

## Requirements

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code)
- [GitHub CLI](https://cli.github.com/) (`gh`) with authentication
- [tmux](https://github.com/tmux/tmux) (for parallel-develop)
- Git with worktree support

## Compatibility

This plugin follows the [Agent Skills](https://agentskills.io) open standard and is compatible with Claude Code, Codex CLI, Gemini CLI, OpenCode, and other supporting agents.
