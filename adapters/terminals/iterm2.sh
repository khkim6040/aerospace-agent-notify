#!/bin/sh

aan_iterm2_window_for_session() {
  [ -n "$1" ] || return 0
  osascript \
    -e 'on run argv' \
    -e 'set targetSession to item 1 of argv' \
    -e 'tell application "iTerm2"' \
    -e 'repeat with w in windows' \
    -e 'repeat with t in tabs of w' \
    -e 'repeat with s in sessions of t' \
    -e 'if id of s is targetSession then return id of w' \
    -e 'end repeat' \
    -e 'end repeat' \
    -e 'end repeat' \
    -e 'end tell' \
    -e 'end run' -- "$1" 2>/dev/null || true
}
