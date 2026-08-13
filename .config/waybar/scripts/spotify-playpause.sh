#!/bin/sh
case "$(playerctl --player=spotify status 2>/dev/null)" in
  Playing) echo '{"text": "󰏤", "class": "playing"}' ;;
  Paused)  echo '{"text": "󰐊", "class": "paused"}' ;;
  *)       echo '{"text": "", "class": "stopped"}' ;;
esac
