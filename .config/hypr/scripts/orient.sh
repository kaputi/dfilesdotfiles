#!/usr/bin/env bash
# Layout/orientation helper.
#
# Two concerns, two binds:
#   - cycle  (Super+W)        : advance focused workspace's master orientation
#                                left → top → right → bottom → center → left.
#                                No-op in dwindle mode.
#   - toggle (Super+SHIFT+W)  : flip master ↔ dwindle. On dwindle→master,
#                                restore each workspace's stored orientation.
#
# Per-workspace state lives in $XDG_RUNTIME_DIR/hypr-orient/<ws_id>.
# Global layout state lives in $XDG_RUNTIME_DIR/hypr-orient/_layout.
#
# Note on flicker (dwindle→master restoration):
# `layoutmsg orientationX` only operates on the focused workspace, so restoring
# per-WS state requires briefly visiting each workspace whose stored value
# differs from its default. To eliminate the flicker:
#   - drop restoration: comment out the loop in restore_master_state, and on
#     dwindle→master Hyprland will reapply each WS's `layoutopt:orientation`
#     rule from hyprland.conf (DP-1 ws 1..9 = left, HDMI-A-1 ws 11..19 = top).
#   - or restore only the focused monitor's focused WS (single dispatch, no
#     focus change).
#   - or switch to the hy3 plugin which keeps per-workspace layout state
#     across general:layout changes.

set -euo pipefail

STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/hypr-orient"
mkdir -p "$STATE_DIR"
GLOBAL_FILE="$STATE_DIR/_layout"

monitors_json() { hyprctl -j monitors; }

active_ws_global() {
    hyprctl -j activeworkspace | jq -r '.id'
}

active_ws_on() {
    local mon=$1
    monitors_json | jq -r --arg m "$mon" '.[] | select(.name==$m) | .activeWorkspace.id // empty'
}

focused_monitor() {
    monitors_json | jq -r '.[] | select(.focused==true) | .name'
}

# Default orientation when no per-WS state exists — matches workspace rules in
# hyprland.conf (ws 1..9 = left, ws 11..19 = top).
default_for() {
    local ws=$1
    if (( ws >= 11 && ws <= 19 )); then echo top; else echo left; fi
}

ws_orient() {
    local ws=$1 f="$STATE_DIR/$ws"
    if [[ -f $f ]]; then cat "$f"; else default_for "$ws"; fi
}

current_layout() {
    if [[ -f $GLOBAL_FILE ]]; then cat "$GLOBAL_FILE"; else echo master; fi
}

signal_waybar() {
    pkill -SIGRTMIN+8 waybar 2>/dev/null || true
}

set_orient_focused() {
    # Master-mode only: dispatch orientation on focused WS, persist its state.
    local o=$1 ws
    ws=$(active_ws_global)
    hyprctl dispatch layoutmsg "orientation${o}" >/dev/null
    echo "$o" > "$STATE_DIR/$ws"
    signal_waybar
}

# Restore per-WS orientations after switching from dwindle back to master.
# Only visits workspaces whose stored state differs from their default — a no-op
# if the user never cycled anything.
restore_master_state() {
    local original_ws original_mon mon ws stored default
    original_ws=$(active_ws_global)
    original_mon=$(focused_monitor)

    # Iterate every workspace pinned by the config (1..9 + 11..19).
    for ws in 1 2 3 4 5 6 7 8 9 11 12 13 14 15 16 17 18 19; do
        [[ -f "$STATE_DIR/$ws" ]] || continue
        stored=$(cat "$STATE_DIR/$ws")
        default=$(default_for "$ws")
        [[ $stored == "$default" ]] && continue
        hyprctl dispatch workspace "$ws" >/dev/null
        hyprctl dispatch layoutmsg "orientation${stored}" >/dev/null
    done

    # Restore focus.
    hyprctl dispatch workspace "$original_ws" >/dev/null
    hyprctl dispatch focusmonitor "$original_mon" >/dev/null
}

set_master() {
    hyprctl keyword general:layout master >/dev/null
    echo master > "$GLOBAL_FILE"
    restore_master_state
    signal_waybar
}

set_dwindle() {
    hyprctl keyword general:layout dwindle >/dev/null
    echo dwindle > "$GLOBAL_FILE"
    signal_waybar
}

resolve_for_monitor() {
    # Glyph state: dwindle if global layout is dwindle, otherwise the orientation
    # of that monitor's currently-focused workspace.
    local mon=${1:-}
    if [[ $(current_layout) == dwindle ]]; then
        echo dwindle
        return
    fi
    local ws
    if [[ -n $mon ]]; then
        ws=$(active_ws_on "$mon")
        [[ -z $ws ]] && { echo _none; return; }
    else
        ws=$(active_ws_global)
    fi
    ws_orient "$ws"
}

glyph() {
    case $1 in
        left)    echo "█ " ;;
        right)   echo " █" ;;
        top)     echo "▀▀" ;;
        bottom)  echo "▄▄" ;;
        center)  echo "■■" ;;
        dwindle) echo "▚▞" ;;
        _none)   echo "" ;;
        *)       echo "··" ;;
    esac
}

cmd=${1:-get}

case $cmd in
    cycle)
        # No-op in dwindle — toggle to master first if you want to cycle.
        [[ $(current_layout) == master ]] || exit 0
        ws=$(active_ws_global)
        case $(ws_orient "$ws") in
            left)   set_orient_focused top ;;
            top)    set_orient_focused right ;;
            right)  set_orient_focused bottom ;;
            bottom) set_orient_focused center ;;
            center) set_orient_focused left ;;
            *)      set_orient_focused left ;;
        esac
        ;;
    toggle)
        if [[ $(current_layout) == master ]]; then
            set_dwindle
        else
            set_master
        fi
        ;;
    left|right|top|bottom|center)
        [[ $(current_layout) == master ]] || set_master
        set_orient_focused "$cmd"
        ;;
    dwindle)
        set_dwindle
        ;;
    master)
        set_master
        ;;
    get)
        glyph "$(resolve_for_monitor "${2:-}")"
        ;;
    name)
        resolve_for_monitor "${2:-}"
        ;;
    *)
        echo "usage: $0 {cycle|toggle|left|right|top|bottom|center|dwindle|master|get [MONITOR]|name [MONITOR]}" >&2
        exit 1
        ;;
esac
