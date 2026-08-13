#!/usr/bin/env bash
echo "=== Pacman + AUR ==="
yay -Syyu

echo ""
echo "=== Flatpak ==="
flatpak update
