#!/bin/bash
# Restarts the wedged xdg-desktop-portal-hyprland/xdg-desktop-portal user services.
# Fixes: OBS "Open Selector" (PipeWire screen capture) doing nothing when clicked.
set -e

echo "Restarting portal services..."
systemctl --user restart xdg-desktop-portal-hyprland.service xdg-desktop-portal.service

sleep 1

if timeout 5 dbus-send --session --print-reply \
    --dest=org.freedesktop.impl.portal.desktop.hyprland \
    /org/freedesktop/portal/desktop org.freedesktop.DBus.Peer.Ping >/dev/null 2>&1; then
    echo "OK: portal is responding. Try screen capture again."
else
    echo "WARNING: portal still not responding after restart."
    exit 1
fi
