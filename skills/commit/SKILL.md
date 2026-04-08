---
name: commit
description: Create a git commit
user-invocable: true
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## Principles

- Commit early and often — prefer many small commits over few large ones
- Each commit should do one thing, so `git revert` can undo it precisely
- Only group changes that are meaningless apart (e.g., SQL query + generated code, proto + generated Go code)
- Keep independent changes in separate commits even if they serve the same feature
- Never squash or rewrite existing commits unless explicitly asked

## Commit Message

Format: `<prefix>: <short description>`

| Category | Patterns | Prefix |
|----------|----------|--------|
| Tests | `*_test.go`, `test_*.py`, `*_test.py`, `tests/` | `test:` |
| Documentation | `*.md`, `docs/`, `README*` | `docs:` |
| Lint/Format | Whitespace, import ordering, formatting only | `lint:` |
| Dependencies | `go.mod`, `go.sum`, `requirements*.txt`, `pyproject.toml` | `chore:` |
| Config | `*.yaml`, `*.yml`, `*.json` configs | `chore:` |
| Database | `migrations/`, `db/queries/` | `chore:` or `feat:` |
| Proto | `proto/**/*.proto` | `feat:` or `fix:` |
| Bug Fix | Error handling, patches, single-line fixes | `fix:` |
| Refactor | Restructuring, renaming, moving code | `refactor:` |
| New Feature | New files, new functions, new capabilities | `feat:` |

Description: imperative mood, lowercase, no period, max 50 chars

## Execute

For each logical unit of work:
1. Stage only those files: `git add <files>`
2. Commit with proper message
3. Proceed to next group

Show `git log --oneline -<N>` when done.
