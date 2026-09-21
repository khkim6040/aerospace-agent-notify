#!/bin/sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
target_home=$HOME
if [ "$#" -gt 0 ]; then [ "$#" = 2 ] && [ "$1" = --home ] && [ -n "$2" ] || { printf '%s\n' 'usage: install.sh [--home PATH]' >&2; exit 64; }; target_home=$2; fi

require() { command -v "$1" >/dev/null 2>&1 || { printf 'missing required command: %s\n' "$1" >&2; exit 1; }; }
[ "$(uname)" = Darwin ] || { printf '%s\n' 'macOS is required' >&2; exit 1; }
require aerospace; require osascript; require python3; require open
open -Ra iTerm >/dev/null 2>&1 || { printf '%s\n' 'iTerm2 is required' >&2; exit 1; }

package_dir="$target_home/.local/share/aerospace-agent-notify"
bin_dir="$target_home/.local/bin"
settings_dir="$target_home/.claude"
settings="$settings_dir/settings.json"
mkdir -p "$package_dir" "$bin_dir" "$settings_dir" "$target_home/.config/aerospace-agent-notify"
cp -R "$repo_root/bin" "$repo_root/lib" "$repo_root/adapters" "$package_dir/"
chmod +x "$package_dir/bin/aerospace-agent-notify" "$package_dir/adapters/agents/claude-code.sh"
ln -sfn "$package_dir/bin/aerospace-agent-notify" "$bin_dir/aerospace-agent-notify"

[ -f "$settings" ] || { umask 077; printf '%s\n' '{"hooks":{}}' > "$settings"; }
stamp=$(date +%Y%m%d%H%M%S)
backup="$settings_dir/settings.json.aerospace-agent-notify.$stamp.bak"
cp "$settings" "$backup"
tmp="$settings_dir/.settings.json.aerospace-agent-notify.tmp"
if ! python3 "$package_dir/lib/settings.py" install "$settings" "$tmp" "$package_dir/adapters/agents/claude-code.sh"; then
  cp "$backup" "$settings"
  rm -f "$tmp"
  exit 1
fi
mv "$tmp" "$settings"
printf '%s\n' 'Installed aerospace-agent-notify. Run aerospace-agent-notify doctor to verify.'
