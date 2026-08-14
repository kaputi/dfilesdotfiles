#!/usr/bin/env bash
# Claude Code status line — macOS compatible (no jq, no plugins)
# Uses python3 (ships with macOS) for JSON parsing

input=$(/bin/cat)

# Parse all JSON fields in one python3 call
eval "$(echo "$input" | python3 -c '
import sys, json
d = json.load(sys.stdin)
def get(path, default=""):
    obj = d
    for k in path.split("."):
        if isinstance(obj, dict):
            obj = obj.get(k, None)
        else:
            return default
    return default if obj is None else obj

print(f"cwd={get(\"workspace.current_dir\")!r}")
print(f"model={get(\"model.display_name\")!r}")
print(f"used_pct={get(\"context_window.used_percentage\")!r}")
print(f"rate_5h={get(\"rate_limits.five_hour.used_percentage\")!r}")
print(f"rate_reset={get(\"rate_limits.five_hour.resets_at\")!r}")
' 2>/dev/null)"

# Colors (basic 256-color — works in Terminal.app)
red=$'\033[31m'
yellow=$'\033[33m'
green=$'\033[32m'
grey=$'\033[90m'
cyan=$'\033[36m'
reset=$'\033[0m'

# Git info
git_branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null ||
  git -C "$cwd" rev-parse --short HEAD 2>/dev/null)

git_part=""
if [[ -n "$git_branch" ]]; then
  dirty=""
  if ! git -C "$cwd" diff --quiet 2>/dev/null ||
    ! git -C "$cwd" diff --cached --quiet 2>/dev/null ||
    [[ -n "$(git -C "$cwd" ls-files --others --exclude-standard 2>/dev/null)" ]]; then
    dirty="*"
  fi
  git_part=" ${yellow}${git_branch}${dirty}${reset}"
fi

# Context window usage badge
ctx_part=""
if [[ -n "$used_pct" ]]; then
  used_int=$(printf '%.0f' "$used_pct")
  ctx_part=" ${cyan}ctx:${used_int}%${reset}"
fi

# Rate limit badge
rate_part=""
if [[ -n "$rate_5h" ]]; then
  rate_int=$(printf '%.0f' "$rate_5h")
  reset_str=""
  if [[ -n "$rate_reset" ]]; then
    now=$(date +%s)
    remaining=$((rate_reset - now))
    if ((remaining > 0)); then
      hours=$((remaining / 3600))
      mins=$(((remaining % 3600) / 60))
      if ((hours > 0)); then
        reset_str="${hours}h${mins}m"
      else
        reset_str="${mins}m"
      fi
    fi
  fi
  if ((rate_int <= 33)); then
    rate_color="$green"
  elif ((rate_int <= 66)); then
    rate_color="$yellow"
  else
    rate_color="$red"
  fi
  rate_part=" ${grey}usage:${reset}${rate_color}${rate_int}%${reset}${grey} - reset:${reset_str}${reset}"
fi

# Model badge
model_part=""
if [[ -n "$model" ]]; then
  model_part="${grey}${model}${reset}"
fi

# Assemble right side
right_parts=()
[[ -n "$model_part" ]] && right_parts+=("$model_part")
[[ -n "$ctx_part" ]] && right_parts+=("$ctx_part")
[[ -n "$rate_part" ]] && right_parts+=("$rate_part")
right=""
for part in "${right_parts[@]}"; do
  right="${right} - ${part}"
done

printf "%s %s" "$git_part" "$right"
