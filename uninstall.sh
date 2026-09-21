#!/bin/sh
set -eu

target_home=$HOME
purge=false
while [ "$#" -gt 0 ]; do
  case "$1" in
    --home) target_home=$2; shift 2 ;;
    --purge-data) purge=true; shift ;;
    *) exit 64 ;;
  esac
done
settings="$target_home/.claude/settings.json"
package_dir="$target_home/.local/share/aerospace-agent-notify"
if [ -f "$settings" ] && [ -f "$package_dir/lib/settings.py" ]; then
  backup="$settings.aerospace-agent-notify.$(date +%Y%m%d%H%M%S).bak"
  cp "$settings" "$backup"
  tmp="$settings.aerospace-agent-notify.tmp"
  python3 "$package_dir/lib/settings.py" remove "$settings" "$tmp" && mv "$tmp" "$settings" || { cp "$backup" "$settings"; rm -f "$tmp"; exit 1; }
fi
rm -f "$target_home/.local/bin/aerospace-agent-notify"
rm -rf "$package_dir"
if [ "$purge" = true ]; then rm -rf "$target_home/.config/aerospace-agent-notify" "$target_home/.cache/aerospace-agent-notify"; fi
