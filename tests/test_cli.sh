#!/bin/sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export TEST_BIN="$tmp/bin"
export AAN_HOME="$tmp/home"
export AAN_QUEUE_FILE="$tmp/queue"
mkdir -p "$TEST_BIN" "$AAN_HOME"

printf '#!/bin/sh\nexit 0\n' > "$TEST_BIN/aerospace"
chmod +x "$TEST_BIN/aerospace"

PATH="$TEST_BIN:$PATH" "$repo_root/bin/aerospace-agent-notify" notify \
  --terminal unknown --session-id example --source test
