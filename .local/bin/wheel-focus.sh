#!/usr/bin/env bash
# Focus window under cursor — called by Hyprland bindn on scroll events

fullscreen=$(hyprctl activewindow -j | jq -r '.fullscreen')
[ "$fullscreen" != "0" ] && exit 0

pos=$(hyprctl cursorpos)
cx=${pos%,*}
cy=${pos##*, }

# Workspace under the cursor: the monitor's visible special workspace if one
# is open (its id is negative), otherwise its regular active workspace.
ws=$(hyprctl monitors -j | jq -r --argjson x "$cx" --argjson y "$cy" '
    [.[] |
        (if (.transform % 2) == 1 then {w: .height, h: .width} else {w: .width, h: .height} end) as $r |
        select($x >= .x and $x < (.x + ($r.w / .scale)) and
               $y >= .y and $y < (.y + ($r.h / .scale))) |
        (if .specialWorkspace.name != "" then .specialWorkspace.id else .activeWorkspace.id end)
    ] | .[0] // empty')
[ -z "$ws" ] && exit 0

addr=$(hyprctl clients -j | jq -r --argjson x "$cx" --argjson y "$cy" --argjson ws "$ws" '
    [.[] | select(
        .workspace.id == $ws and .mapped == true and .hidden == false and
        .at[0] <= $x and $x < (.at[0] + .size[0]) and
        .at[1] <= $y and $y < (.at[1] + .size[1])
    )] | sort_by([if .floating then 0 else 1 end, .focusHistoryID]) | .[0].address // empty')

[ -n "$addr" ] && hyprctl dispatch focuswindow "address:$addr" >/dev/null
