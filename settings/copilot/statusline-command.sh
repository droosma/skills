#!/usr/bin/env bash
# Copilot CLI status line: repo | branch | context bar | cost | velocity | model
# Full truecolor (24-bit) RGB color-coding — mirrors the Claude Code status line.
#
# Wired up via ~/.copilot/settings.json:
#   "statusLine": { "type": "command", "command": "bash D:/skills/settings/copilot/statusline-command.sh" }
#
# Copilot invokes this in the interactive TUI only (not in -p/non-interactive
# mode), passing the current session status as JSON on stdin. It expects the
# status line text on stdout.
#
# Like the Claude script this deliberately avoids `jq` (not guaranteed on PATH
# in the Git Bash shell Copilot spawns on Windows) and extracts JSON fields
# with grep/sed. The helpers are nesting-agnostic: they find a key wherever it
# appears, so both flat (`used_percentage`) and nested
# (`context_window.used_percentage`, `model.display_name`) payload shapes work.
#
# DEBUG: set COPILOT_STATUSLINE_DEBUG=1 to dump the raw stdin payload to
# /tmp/copilot-status-payload.json so the exact field names can be verified and
# this script tuned to match.

input=$(cat)

if [ "${COPILOT_STATUSLINE_DEBUG:-0}" = "1" ]; then
  printf '%s' "$input" > /tmp/copilot-status-payload.json
fi

flat=$(printf '%s' "$input" | tr -d '\r\n')

c()    { printf '\x1b[38;2;%d;%d;%dm' "$1" "$2" "$3"; }
bold() { printf '\x1b[1m'; }
reset() { printf '\x1b[0m'; }

DIM="$(c 60 60 60)"
SEP=" ${DIM}|$(reset) "

# $1 = scope text, $2 = key -> quoted string value
get_str() {
  printf '%s' "$1" | grep -o "\"$2\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | head -n1 \
    | sed -E 's/.*:[[:space:]]*"//; s/"$//'
}
# $1 = scope text, $2 = key -> bare numeric value
get_num() {
  printf '%s' "$1" | grep -o "\"$2\"[[:space:]]*:[[:space:]]*[-0-9][0-9.eE+-]*" | head -n1 \
    | sed -E 's/.*:[[:space:]]*//'
}
# $1 = scope text, $2 = key -> flat (non-nested) sub-object text
get_obj() {
  printf '%s' "$1" | grep -o "\"$2\"[[:space:]]*:[[:space:]]*{[^}]*}"
}

# --- working directory (several possible key names across versions) ---
dir=$(get_str "$flat" cwd)
[ -z "$dir" ] && dir=$(get_str "$flat" current_dir)
[ -z "$dir" ] && dir=$(get_str "$flat" workingDirectory)
[ -z "$dir" ] && dir=$(get_str "$flat" directory)
[ -z "$dir" ] && dir="$PWD"

# --- repo name (bold yellow) ---
repo_obj=$(get_obj "$flat" repo)
repo=$(get_str "$repo_obj" name)
[ -z "$repo" ] && repo=$(git -C "$dir" --no-optional-locks rev-parse --show-toplevel 2>/dev/null | xargs -r basename)
[ -z "$repo" ] && repo=$(basename "$dir")
repo_seg="$(bold)$(c 220 200 0)${repo}$(reset)"

# --- git branch (bold cyan) ---
branch=$(git -C "$dir" --no-optional-locks branch --show-current 2>/dev/null)
branch_seg=""
[ -n "$branch" ] && branch_seg="$(bold)$(c 0 220 220)(🌿 ${branch})$(reset)"

# --- context usage bar (nesting-agnostic: matches context_window.used_percentage) ---
used_pct=$(get_num "$flat" used_percentage)
[ -z "$used_pct" ] && used_pct=$(get_num "$flat" usedPercentage)
[ -z "$used_pct" ] && used_pct=$(get_num "$flat" percent_used)
used_int=$(printf '%.0f' "${used_pct:-0}" 2>/dev/null || echo 0)

total_blocks=20
denom=$((total_blocks - 1))
filled=$(( used_int * total_blocks / 100 ))
[ "$filled" -gt "$total_blocks" ] && filled=$total_blocks

bar=""
for ((i = 1; i <= total_blocks; i++)); do
  if [ "$i" -le "$filled" ]; then
    frac=$(( (i - 1) * 100 / denom ))
    if [ "$frac" -le 50 ]; then
      t=$(( frac * 2 ))
      r=$(( 0 + 220 * t / 100 ))
      g=200
      b=$(( 80 - 80 * t / 100 ))
    else
      t=$(( (frac - 50) * 2 ))
      r=220
      g=$(( 200 - 160 * t / 100 ))
      b=$(( 20 * t / 100 ))
    fi
    bar="${bar}$(c "$r" "$g" "$b")█"
  else
    bar="${bar}$(c 60 60 60)█"
  fi
done
bar="${bar}$(reset)"

if [ "$used_int" -lt 20 ]; then
  emoji="🟢"; pct_color="$(c 0 200 80)"
elif [ "$used_int" -lt 70 ]; then
  emoji="⚡"; pct_color="$(c 220 200 0)"
elif [ "$used_int" -lt 90 ]; then
  emoji="🔥"; pct_color="$(c 255 100 0)"
else
  emoji="🚨"; pct_color="$(c 255 0 0)"
fi
context_seg="${bar} ${emoji} ${pct_color}${used_int}%$(reset)"

# --- session cost in USD, derived from AI credits used (yellow) ---
# Copilot's payload carries no currency value, only AI credits:
#   ai_used.formatted (e.g. "0.58") and ai_used.total_nano_aiu (1 AIC = 1e9 nano).
# 1 AIC ≈ 1 US cent, so USD = AIC × 0.01. Override with COPILOT_USD_PER_AIC.
USD_PER_AIC="${COPILOT_USD_PER_AIC:-0.01}"

cost_seg=""
ai_used_obj=$(get_obj "$flat" ai_used)
aiu=$(get_str "$ai_used_obj" formatted)
[ -z "$aiu" ] && aiu=$(get_num "$flat" total_nano_aiu | awk '{printf "%.6f", $1/1000000000}')
if [ -n "$aiu" ]; then
  usd=$(awk -v a="$aiu" -v r="$USD_PER_AIC" 'BEGIN{printf "%.2f", a*r}' 2>/dev/null)
  [ -n "$usd" ] && cost_seg="$(c 220 200 0)\$${usd}$(reset)"
fi

# --- code velocity from uncommitted working-tree changes ---
added=0; removed=0
while IFS=$'\t' read -r a r _; do
  [[ "$a" =~ ^[0-9]+$ ]] && added=$((added + a))
  [[ "$r" =~ ^[0-9]+$ ]] && removed=$((removed + r))
done < <(git -C "$dir" --no-optional-locks diff --numstat 2>/dev/null)
velocity_seg="$(c 0 200 80)+${added}$(reset) $(c 220 40 20)-${removed}$(reset)"

# --- model (magenta) ---
model_obj=$(get_obj "$flat" model)
model=$(get_str "$model_obj" display_name)
[ -z "$model" ] && model=$(get_str "$flat" display_name)
[ -z "$model" ] && model=$(get_str "$model_obj" id)
[ -z "$model" ] && model=$(get_str "$flat" model)
model_seg=""
[ -n "$model" ] && model_seg="$(c 200 0 200)🤖 ${model}$(reset)"

# --- session name (dim, if present) ---
session=$(get_str "$flat" session_name)
session_seg=""
[ -n "$session" ] && session_seg="$(c 120 120 120)⟨${session}⟩$(reset)"

# --- assemble ---
line="$repo_seg"
[ -n "$branch_seg" ]  && line="${line}${SEP}${branch_seg}"
line="${line}${SEP}${context_seg}"
[ -n "$cost_seg" ]    && line="${line}${SEP}${cost_seg}"
line="${line}${SEP}${velocity_seg}"
[ -n "$model_seg" ]   && line="${line}${SEP}${model_seg}"
[ -n "$session_seg" ] && line="${line}${SEP}${session_seg}"

printf '%s\n' "$line"
