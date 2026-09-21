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
