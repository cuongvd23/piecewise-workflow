#!/bin/bash
# Open a tmux pane with a coding agent in a worktree and send an initial message.
# Usage: spawn-worker.sh <worktree-path> <message> [--agent claude|codex|pi|opencode|gemini] [--model <model>]
set -e

usage() {
	printf 'Usage: %s <worktree-path> <message> [--agent claude|codex|pi|opencode|gemini] [--model <model>]\n' "$0" >&2
}

fail() {
	printf '%s\n' "$1" >&2
	exit 1
}

worktree_path="${1:-}"
message="${2:-}"
agent="claude"
model=""

if [ -z "$worktree_path" ] || [ -z "$message" ]; then
	usage
	exit 1
fi
shift 2

while [ "$#" -gt 0 ]; do
	case "$1" in
		--agent|--model)
			[ -n "${2:-}" ] && [[ "$2" != --* ]] || fail "Missing value for $1"
			if [ "$1" = "--agent" ]; then
				agent="$2"
			else
				model="$2"
			fi
			shift 2
			;;
		*)
			usage
			fail "Unknown option: $1"
			;;
	esac
done

case "$agent" in
	claude|codex|pi|opencode|gemini) ;;
	*) fail "Unsupported agent: $agent (choose claude, codex, pi, opencode, or gemini)" ;;
esac

[ -d "$worktree_path" ] || fail "Directory not found: $worktree_path"
command -v tmux >/dev/null 2>&1 || fail "Required executable not found: tmux"
command -v "$agent" >/dev/null 2>&1 || fail "Required executable not found: $agent"
worktree_path=$(cd -- "$worktree_path" && pwd -P)

prompt="Investigate the task and follow the repository's AGENTS.md and CLAUDE.md guidance. Present an implementation plan and wait for the user's approval before implementing or modifying files.

$message"

worker_cmd=("$agent")
case "$agent" in
	claude) worker_cmd+=(--permission-mode plan) ;;
	opencode) worker_cmd+=(--agent plan) ;;
	gemini) worker_cmd+=(--approval-mode plan) ;;
esac
[ -z "$model" ] || worker_cmd+=(--model "$model")
case "$agent" in
	opencode) worker_cmd+=(--prompt "$prompt") ;;
	gemini) worker_cmd+=(--prompt-interactive "$prompt") ;;
	*) worker_cmd+=(-- "$prompt") ;;
esac

# Pass arguments directly to tmux without interpolating a shell command.
current_pane=$(tmux display-message -p '#{pane_id}')
pane_id=$(tmux split-window -h -P -F '#{pane_id}' -t "$current_pane" \
	-c "$worktree_path" "${worker_cmd[@]}")

printf '%s\n' "$pane_id"
