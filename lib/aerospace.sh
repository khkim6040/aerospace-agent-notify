#!/bin/sh

aan_focused_workspace() {
  aerospace list-workspaces --focused 2>/dev/null
}

aan_workspace_for_window() {
  aerospace list-windows --all --format '%{window-id} %{workspace}' 2>/dev/null |
    awk -v window="$1" 'index($0, window " ") == 1 { print substr($0, length(window) + 2); exit }'
}
