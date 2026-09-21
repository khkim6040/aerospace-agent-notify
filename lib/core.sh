#!/bin/sh

aan_queue_file() {
  printf '%s\n' "${AAN_QUEUE_FILE:-${XDG_CACHE_HOME:-$HOME/.cache}/aerospace-agent-notify/waiting-workspaces}"
}

aan_enqueue_workspace() {
  workspace=$1
  queue=$(aan_queue_file)
  mkdir -p "$(dirname "$queue")" 2>/dev/null || return 0
  lock="$queue.lock"
  ( umask 077; mkdir "$lock" 2>/dev/null ) || return 0
  trap 'rmdir "$lock" 2>/dev/null' EXIT HUP INT TERM
  touch "$queue" 2>/dev/null || return 0
  grep -Fqx "$workspace" "$queue" 2>/dev/null || printf '%s\n' "$workspace" >> "$queue"
  rmdir "$lock" 2>/dev/null
  trap - EXIT HUP INT TERM
}

aan_show_notification() {
  osascript -e 'on run argv' -e 'display notification ("Workspace " & item 1 of argv & " is waiting") with title "Agent Notify"' -e 'end run' -- "$1" >/dev/null 2>&1 || true
}

aan_notify_workspace() {
  workspace=$1
  [ -n "$workspace" ] || return 0
  focused=$(aan_focused_workspace) || return 0
  [ "$workspace" = "$focused" ] && return 0
  aan_enqueue_workspace "$workspace"
  aan_show_notification "$workspace"
}

aan_notify_window() {
  workspace=$(aan_workspace_for_window "$1") || return 0
  aan_notify_workspace "$workspace"
}
