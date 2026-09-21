#!/bin/sh
set -eu

[ -n "${ITERM_SESSION_ID:-}" ] || exit 0
adapter_root=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
exec "$adapter_root/bin/aerospace-agent-notify" notify --terminal iterm2 --session-id "${ITERM_SESSION_ID#*:}" --source claude-code
