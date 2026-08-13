#!/usr/bin/env bash
set -euo pipefail

mapfile -t rows < <(hyprctl clients -j | jq -r '
  sort_by(.workspace.id, .class)
  | .[]
  | [
      .address,
      "[\(.workspace.name)]  \(.title | gsub("\t"; " "))",
      (.class as $c | "\($c),\($c | ascii_downcase),\($c | ascii_downcase | sub("^.*\\."; "")),application-x-executable")
    ]
  | @tsv
')

(( ${#rows[@]} == 0 )) && exit 0

selected=$(
  for row in "${rows[@]}"; do
    IFS=$'\t' read -r _addr display icon <<<"$row"
    printf '%s\0icon\x1f%s\n' "$display" "$icon"
  done | fuzzel --dmenu --prompt "window: "
)

[ -z "$selected" ] && exit 0

for row in "${rows[@]}"; do
  IFS=$'\t' read -r addr display _icon <<<"$row"
  if [ "$display" = "$selected" ]; then
    hyprctl dispatch focuswindow "address:$addr"
    exit 0
  fi
done
