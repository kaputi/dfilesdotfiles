#!/bin/sh
text=$(playerctl --player=spotify metadata --format '󰓇 {{artist}} – {{title}}' 2>/dev/null) || echo '{"text": "", "class": "stopped"}'
[ -n "$text" ] && printf '{"text": "%s", "class": "playing"}\n' "$(echo "$text" | sed 's/\\/\\\\/g; s/"/\\"/g')"
