#!/usr/bin/env bash
# ws.sh switch N  → switch to workspace N on the monitor under the cursor
# ws.sh move N    → move focused window to workspace N on the monitor under the cursor (silent, no follow)
#
# Picks the target monitor from cursor position, so it works regardless of
# focus/follow_mouse settings (matches AwesomeWM behavior).
#
# Per-monitor workspace numbering:
#   DP-1     → workspaces 1-9
#   HDMI-A-1 → workspaces 11-19
set -e
action=$1
n=$2

read cx cy < <(hyprctl cursorpos -j | jq -r '"\(.x) \(.y)"')

mon=$(hyprctl monitors -j | jq -r --argjson cx "$cx" --argjson cy "$cy" '
  .[] |
  (if (.transform == 1 or .transform == 3) then {w: .height, h: .width} else {w: .width, h: .height} end) as $r
  | select($cx >= .x and $cx < (.x + ($r.w / .scale))
        and $cy >= .y and $cy < (.y + ($r.h / .scale)))
  | .name
' | head -n1)

case "$mon" in
  DP-1)     id=$n ;;
  HDMI-A-1) id=$((10 + n)) ;;
  *)        echo "ws.sh: cursor not on a known monitor (got '$mon' at $cx,$cy)" >&2; exit 1 ;;
esac

case "$action" in
  switch)
    # Hide any visible special workspaces before switching
    visible=$(hyprctl monitors -j | jq -r '.[].specialWorkspace.name | select(. != "")')
    for sw in $visible; do
      case "$sw" in
        special:stash|special:thundermail)
          hyprctl dispatch togglespecialworkspace "${sw#special:}" >/dev/null ;;
      esac
    done
    hyprctl dispatch workspace "$id" ;;
  move)
    hyprctl dispatch movetoworkspacesilent "$id"
    # To follow the window to its new workspace, use this instead:
    # hyprctl dispatch movetoworkspace "$id"
    ;;
  *)      echo "ws.sh: unknown action '$action' (use: switch | move)" >&2; exit 1 ;;
esac
