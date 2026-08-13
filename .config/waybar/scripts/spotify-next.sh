#!/bin/sh
playerctl --player=spotify status >/dev/null 2>&1 && echo '{"text": "󰒭", "class": "playing"}' || echo '{"text": "", "class": "stopped"}'
