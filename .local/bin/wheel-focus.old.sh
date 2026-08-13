#!/usr/bin/env bash
# Focus window under cursor on scroll wheel — gives wheel the same power as a click

DEVICE_NAME="${1:?Usage: $0 <exact-device-name>}"

resolve_device() {
    awk -v name="$DEVICE_NAME" '
        /^N: Name=/ { n = $0; sub(/^N: Name="/, "", n); sub(/"$/, "", n) }
        /^H: Handlers=/ && n == name && /mouse[0-9]/ {
            split($0, a, " ")
            for (i in a)
                if (a[i] ~ /^event[0-9]+$/) { print "/dev/input/" a[i]; exit }
        }
    ' /proc/bus/input/devices
}

DEVICE=""
for i in $(seq 1 60); do
    DEVICE=$(resolve_device)
    [ -n "$DEVICE" ] && break
    sleep 5
done

if [ -z "$DEVICE" ]; then
    echo "wheel-focus: '$DEVICE_NAME' not found after 5 minutes, giving up" >&2
    exit 1
fi

echo "wheel-focus: watching $DEVICE ($DEVICE_NAME)" >&2

focus_under_cursor() {
    local pos cx cy ws addr fullscreen
    fullscreen=$(hyprctl activewindow -j | jq -r '.fullscreen')
    [ "$fullscreen" != "0" ] && return
    pos=$(hyprctl cursorpos)
    cx=${pos%,*}
    cy=${pos##*, }
    ws=$(hyprctl activeworkspace -j | jq -r '.id')
    addr=$(hyprctl clients -j | jq -r --argjson x "$cx" --argjson y "$cy" --argjson ws "$ws" '
        [.[] | select(
            .workspace.id == $ws and .mapped == true and .hidden == false and
            .at[0] <= $x and $x < (.at[0] + .size[0]) and
            .at[1] <= $y and $y < (.at[1] + .size[1])
        )] | sort_by(-.focusHistoryID) | .[0].address // empty')
    [ -n "$addr" ] && hyprctl dispatch focuswindow "address:$addr" >/dev/null
}

stdbuf -oL libinput debug-events --device "$DEVICE" 2>/dev/null | \
    grep --line-buffered -E 'POINTER_(SCROLL|AXIS)' | \
    while read -r _; do
        focus_under_cursor
    done
