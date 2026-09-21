#!/bin/sh
set -eu

[ -n "${ITERM_SESSION_ID:-}" ] || exit 0
exec aerospace-agent-notify notify --terminal iterm2 --session-id "${ITERM_SESSION_ID#*:}" --source claude-code
