#!/bin/bash
# Open a tmux pane with Claude Code in a worktree, auto-trust, and send initial message
# Usage: spawn-worker.sh <worktree-path> <message> [--model <model>]
set -e

worktree_path="${1:-}"
message="${2:-}"
model=""
[ "${3:-}" = "--model" ] && model="${4:-}"

[ -z "$worktree_path" ] || [ -z "$message" ] &&
	echo "Usage: $0 <worktree-path> <message> [--model <model>]" && exit 1
[ ! -d "$worktree_path" ] && echo "Directory not found: $worktree_path" && exit 1

# Open tmux pane with claude
claude_cmd="claude${model:+ --model '$model'}"
current_pane=$(tmux display-message -p '#{pane_id}')
pane_id=$(tmux split-window -h -P -F '#{pane_id}' -t "$current_pane" \
	"cd '$worktree_path' && $claude_cmd")

# Background: auto-trust → wait for ready → send message
(
	for i in $(seq 1 15); do
		sleep 2
		content=$(tmux capture-pane -t "$pane_id" -p 2>/dev/null || true)
		if echo "$content" | grep -qi "trust"; then
			# Trust prompt is a selection UI with "Yes" pre-selected — just press Enter
			tmux send-keys -t "$pane_id" Enter
			sleep 2
			break
		fi
		echo "$content" | grep -q "INSERT" && break
	done
	for i in $(seq 1 30); do
		sleep 2
		tmux capture-pane -t "$pane_id" -p 2>/dev/null | grep -q "INSERT" && break
	done
	sleep 1
	tmux send-keys -t "$pane_id" BTab
	sleep 1
	echo -n "$message" | tmux load-buffer -
	tmux paste-buffer -p -t "$pane_id"
	sleep 1
	tmux send-keys -t "$pane_id" Enter
) &

echo "$pane_id"
