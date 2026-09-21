#!/bin/sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export TEST_BIN="$tmp/bin"
export AAN_HOME="$tmp/home"
export AAN_QUEUE_FILE="$tmp/queue"
mkdir -p "$TEST_BIN" "$AAN_HOME"

cat > "$TEST_BIN/aerospace" <<'EOF'
#!/bin/sh
case "$*" in
  'list-workspaces --focused') printf '%s\n' "$FAKE_FOCUSED" ;;
  'list-windows --all --format %{window-id} %{workspace}') printf '%s\n' "$FAKE_WINDOWS" ;;
esac
EOF
chmod +x "$TEST_BIN/aerospace"

cat > "$TEST_BIN/osascript" <<'EOF'
#!/bin/sh
printf '%s\n' "$*" >> "$OSASCRIPT_LOG"
EOF
chmod +x "$TEST_BIN/osascript"
export OSASCRIPT_LOG="$tmp/osascript.log"

run_notify() {
  PATH="$TEST_BIN:$PATH" sh -c '. "$1/lib/aerospace.sh"; . "$1/lib/core.sh"; aan_notify_window "$2"' sh "$repo_root" "$1"
}

FAKE_FOCUSED=1 FAKE_WINDOWS='42 1' run_notify 42
[ ! -e "$AAN_QUEUE_FILE" ]

FAKE_FOCUSED=1 FAKE_WINDOWS='42 project alpha' run_notify 42
grep -Fx 'project alpha' "$AAN_QUEUE_FILE"
[ "$(wc -l < "$OSASCRIPT_LOG" | tr -d ' ')" = 1 ]

FAKE_FOCUSED=1 FAKE_WINDOWS='42 project alpha' run_notify 42
[ "$(grep -Fxc 'project alpha' "$AAN_QUEUE_FILE")" = 1 ]

rm -f "$AAN_QUEUE_FILE"
FAKE_FOCUSED=1 FAKE_WINDOWS='99 another' run_notify 42
[ ! -e "$AAN_QUEUE_FILE" ]

: > "$OSASCRIPT_LOG"
PATH="$repo_root/bin:$TEST_BIN:$PATH" ITERM_SESSION_ID='w0t0p0:ABC-123' \
  "$repo_root/adapters/agents/claude-code.sh"
grep -F 'ABC-123' "$OSASCRIPT_LOG"
! grep -F 'w0t0p0:ABC-123' "$OSASCRIPT_LOG"

PATH="$repo_root/bin:$TEST_BIN:$PATH" env -u ITERM_SESSION_ID \
  "$repo_root/adapters/agents/claude-code.sh"

set +e
PATH="$repo_root/bin:$TEST_BIN:$PATH" "$repo_root/bin/aerospace-agent-notify" notify \
  --terminal ghostty --session-id example --source test
status=$?
set -e
[ "$status" = 64 ]
[ ! -e "$AAN_QUEUE_FILE" ]

cat > "$TEST_BIN/open" <<'EOF'
#!/bin/sh
exit 0
EOF
chmod +x "$TEST_BIN/open"
install_home="$tmp/install-home"
mkdir -p "$install_home/.claude"
printf '%s' '{"hooks":{"Stop":[{"hooks":[{"command":"other"}]}]}}' > "$install_home/.claude/settings.json"
PATH="$TEST_BIN:$PATH" sh "$repo_root/install.sh" --home "$install_home"
python3 -c 'import json,sys; json.load(open(sys.argv[1]))' "$install_home/.claude/settings.json"
grep -F 'other' "$install_home/.claude/settings.json"
grep -F 'aerospace-agent-notify' "$install_home/.claude/settings.json"
find "$install_home/.claude" -name 'settings.json.aerospace-agent-notify.*.bak' | grep .
