#!/usr/bin/env bash
# Claude Code status line — mirrors Powerlevel10k Pure style
# Left:  <cwd>  <git branch><dirty>
# Right: <model>  <context usage>

input=$(/bin/cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name // ""')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
# cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
rate_5h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
rate_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')

# Shorten home prefix
# home="$HOME"
# display_cwd="${cwd/#$home/~}"

# Colors (ANSI — terminal dims them in the status bar)
red=$'\033[38;2;255;92;87m'
yellow=$'\033[38;2;243;249;157m'
green=$'\033[38;2;152;251;152m'
grey=$'\033[38;5;242m'
cyan=$'\033[38;2;154;237;254m'
reset=$'\033[0m'

# Git info using git -C so we don't need to cd
git_branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null ||
  git -C "$cwd" rev-parse --short HEAD 2>/dev/null)

git_part=""
if [[ -n "$git_branch" ]]; then
  dirty=""
  # Check for staged, unstaged or untracked changes
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

# # Cost badge
# cost_part=""
# if [[ -n "$cost" ]]; then
#   cost_fmt=$(printf '$%.2f' "$cost")
#   cost_part=" ${yellow}${cost_fmt}${reset}"
# fi

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

# Project / directory name badge (basename of cwd)
project_part=""
if [[ -n "$cwd" ]]; then
  project_name=$(basename "$cwd")
  project_part="${red}${project_name}${reset}"
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
# [[ -n "$cost_part" ]] && right_parts+=("$cost_part")
[[ -n "$rate_part" ]] && right_parts+=("$rate_part")
right=""
for part in "${right_parts[@]}"; do
  right="${right} - ${part}"
done

printf "%s%s %s" "$project_part" "$git_part" "$right"
# printf "${red}%s${reset}%s%s" "$display_cwd" "$git_part" "$right"
