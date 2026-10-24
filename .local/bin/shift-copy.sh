#!/usr/bin/env bash
# Copy the primary selection to the clipboard, with a toast — called by the
# Shift+release bind in hyprland.lua (WezTerm's own Shift+release, system-wide)

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

# let the app publish its primary selection after the button release
sleep 0.1

wl-paste --primary --no-newline --type text >"$tmp" 2>/dev/null || exit 0
[[ -s $tmp ]] || exit 0
wl-paste --no-newline --type text 2>/dev/null | cmp -s - "$tmp" && exit 0

wl-copy <"$tmp"
notify-send -a Hyprland -t 1000 -h boolean:transient:true Copied "$(wc -m <"$tmp") chars to clipboard"
