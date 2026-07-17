#!/usr/bin/env bash
# Claude Code status line: repo | branch | context bar | cost | velocity | model
# Full truecolor (24-bit) RGB color-coding.
#
# Deliberately does NOT use `jq`: it is not guaranteed to be on PATH inside
# the Git Bash environment Claude Code spawns to run statusLine commands on
# Windows, and every jq call silently failing was the root cause of missing
# fields here previously. JSON fields are extracted with grep/sed instead,
# which ship with Git Bash.

input=$(cat)
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

cwd_val=$(get_str "$flat" cwd)
current_dir=$(get_str "$flat" current_dir)
project_dir=$(get_str "$flat" project_dir)
dir="${project_dir:-${current_dir:-$cwd_val}}"

# --- repo name (bold yellow) ---
repo_obj=$(get_obj "$flat" repo)
repo=$(get_str "$repo_obj" name)
[ -z "$repo" ] && repo=$(basename "$dir")
repo_seg="$(bold)$(c 220 200 0)${repo}$(reset)"

# --- git branch (bold cyan, wrapped in parens with leaf) ---
branch=$(git -C "$dir" --no-optional-locks branch --show-current 2>/dev/null)
branch_seg=""
[ -n "$branch" ] && branch_seg="$(bold)$(c 0 220 220)(🌿 ${branch})$(reset)"

# --- context usage bar (20 blocks, green -> yellow -> red gradient) ---
used_pct=$(get_num "$flat" used_percentage)
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
  emoji="🟢"
  pct_color="$(c 0 200 80)"
elif [ "$used_int" -lt 70 ]; then
  emoji="⚡"
  pct_color="$(c 220 200 0)"
elif [ "$used_int" -lt 90 ]; then
  emoji="🔥"
  pct_color="$(c 255 100 0)"
else
  emoji="🚨"
  pct_color="$(c 255 0 0)"
fi
context_seg="${bar} ${emoji} ${pct_color}${used_int}%$(reset)"

# --- session cost (yellow) ---
# Only shown if this Claude Code build actually sends a "cost" object; no
# fabricated fallback since there is no verified pricing source to derive it.
cost_obj=$(get_obj "$flat" cost)
cost=$(get_num "$cost_obj" total_cost_usd)
cost_seg=""
if [ -n "$cost" ]; then
  cost_fmt=$(printf '%.2f' "$cost" 2>/dev/null || echo "$cost")
  cost_seg="$(c 220 200 0)\$${cost_fmt}$(reset)"
fi

# --- code velocity (+lines green, -lines red) ---
added=$(get_num "$cost_obj" total_lines_added)
removed=$(get_num "$cost_obj" total_lines_removed)
if [ -z "$added" ] && [ -z "$removed" ]; then
  # cost.total_lines_* not present in this payload; derive velocity from
  # uncommitted working-tree changes instead.
  added=0
  removed=0
  while IFS=$'\t' read -r a r _; do
    [[ "$a" =~ ^[0-9]+$ ]] && added=$((added + a))
    [[ "$r" =~ ^[0-9]+$ ]] && removed=$((removed + r))
  done < <(git -C "$dir" --no-optional-locks diff --numstat 2>/dev/null)
fi
velocity_seg="$(c 0 200 80)+${added}$(reset) $(c 220 40 20)-${removed}$(reset)"

# --- model (magenta) ---
model_obj=$(get_obj "$flat" model)
model=$(get_str "$model_obj" display_name)
[ -z "$model" ] && model=$(get_str "$model_obj" id)
model_seg="$(c 200 0 200)🤖 ${model}$(reset)"

# --- assemble ---
line="$repo_seg"
[ -n "$branch_seg" ] && line="${line}${SEP}${branch_seg}"
line="${line}${SEP}${context_seg}"
[ -n "$cost_seg" ] && line="${line}${SEP}${cost_seg}"
line="${line}${SEP}${velocity_seg}"
line="${line}${SEP}${model_seg}"

printf '%s\n' "$line"
