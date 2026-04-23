#!/usr/bin/env bash
#
# Symlinks skills from this repo into AI coding tool config directories.
# Interactive multi-select for both tools and skills.
# Will NOT overwrite existing skills — only creates new symlinks.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── Tool definitions ────────────────────────────────────────────────
declare -A TOOL_PATHS
TOOL_PATHS=(
    ["Copilot CLI"]="$HOME/.copilot/skills"
    ["Claude Code"]="$HOME/.claude/skills"
    ["OpenCode"]="$HOME/.config/opencode/skills"
)
TOOL_ORDER=("Copilot CLI" "Claude Code" "OpenCode")

# ── Discover skills ────────────────────────────────────────────────
SKILLS=()
while IFS= read -r -d '' dir; do
    name="$(basename "$dir")"
    [[ "$name" == .* ]] && continue
    SKILLS+=("$name")
done < <(find "$SCRIPT_DIR" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

if [[ ${#SKILLS[@]} -eq 0 ]]; then
    echo "❌ No skill folders found in repo."
    exit 1
fi

# ── Colors ──────────────────────────────────────────────────────────
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
DIM='\033[2m'
BOLD='\033[1m'
RESET='\033[0m'

# ── Interactive multi-select (pure bash, no dependencies) ──────────
# Usage: multi_select result_var "Title" item1 item2 ...
# Sets the named array variable to selected items.
multi_select() {
    local -n _result=$1
    local title="$2"
    shift 2
    local items=("$@")
    local count=${#items[@]}

    # All selected by default
    local selected=()
    for (( i=0; i<count; i++ )); do selected+=(1); done
    local cursor=0

    # Hide cursor
    printf '\e[?25l'
    trap 'printf "\e[?25h"' RETURN

    echo ""
    printf "  ${CYAN}%s${RESET}\n" "$title"
    printf "  ${DIM}(↑/↓ navigate, Space toggle, a select all, n select none, Enter confirm)${RESET}\n\n"

    render() {
        # Move cursor up to redraw
        if [[ ${1:-} == "redraw" ]]; then
            printf "\e[%dA" "$count"
        fi
        for (( i=0; i<count; i++ )); do
            local marker="[ ]"
            [[ ${selected[$i]} -eq 1 ]] && marker="[✔]"
            if [[ $i -eq $cursor ]]; then
                printf " ${BOLD}▸ %s %s${RESET}\e[K\n" "$marker" "${items[$i]}"
            else
                printf "   %s %s\e[K\n" "$marker" "${items[$i]}"
            fi
        done
    }

    render "first"

    while true; do
        # Read a single keypress
        IFS= read -rsn1 key
        case "$key" in
            $'\x1b')  # Escape sequence (arrow keys)
                read -rsn2 seq
                case "$seq" in
                    '[A') (( cursor > 0 )) && (( cursor-- )) ;;          # Up
                    '[B') (( cursor < count-1 )) && (( cursor++ )) ;;    # Down
                esac
                ;;
            ' ')  # Space — toggle
                if [[ ${selected[$cursor]} -eq 1 ]]; then
                    selected[$cursor]=0
                else
                    selected[$cursor]=1
                fi
                ;;
            'a'|'A')  # Select all
                for (( i=0; i<count; i++ )); do selected[$i]=1; done
                ;;
            'n'|'N')  # Select none
                for (( i=0; i<count; i++ )); do selected[$i]=0; done
                ;;
            '')  # Enter
                break
                ;;
        esac
        render "redraw"
    done

    echo ""

    _result=()
    for (( i=0; i<count; i++ )); do
        [[ ${selected[$i]} -eq 1 ]] && _result+=("${items[$i]}")
    done
}

# ── Step 1: Select tools ───────────────────────────────────────────
selected_tools=()
multi_select selected_tools "Select target tools:" "${TOOL_ORDER[@]}"

if [[ ${#selected_tools[@]} -eq 0 ]]; then
    printf "${YELLOW}⚠  No tools selected. Exiting.${RESET}\n"
    exit 0
fi

# ── Step 2: Select skills ──────────────────────────────────────────
selected_skills=()
multi_select selected_skills "Select skills to link:" "${SKILLS[@]}"

if [[ ${#selected_skills[@]} -eq 0 ]]; then
    printf "${YELLOW}⚠  No skills selected. Exiting.${RESET}\n"
    exit 0
fi

# ── Step 3: Create symlinks ────────────────────────────────────────
created=0
skipped=0
errors=0

for tool in "${selected_tools[@]}"; do
    target_dir="${TOOL_PATHS[$tool]}"
    printf "\n${CYAN}📁 %s → %s${RESET}\n" "$tool" "$target_dir"

    mkdir -p "$target_dir"

    for skill in "${selected_skills[@]}"; do
        link_path="$target_dir/$skill"
        source_path="$SCRIPT_DIR/$skill"

        if [[ -e "$link_path" || -L "$link_path" ]]; then
            printf "   ${YELLOW}⏭  %s (already exists — skipped)${RESET}\n" "$skill"
            (( skipped++ ))
            continue
        fi

        if ln -s "$source_path" "$link_path" 2>/dev/null; then
            printf "   ${GREEN}✅ %s → linked${RESET}\n" "$skill"
            (( created++ ))
        else
            printf "   ${RED}❌ %s — symlink failed${RESET}\n" "$skill"
            (( errors++ ))
        fi
    done
done

# ── Summary ─────────────────────────────────────────────────────────
printf "\n${DIM}── Summary ───────────────────────────────${RESET}\n"
printf "   ${GREEN}Created : %d${RESET}\n" "$created"
printf "   ${YELLOW}Skipped : %d${RESET}\n" "$skipped"
if [[ $errors -gt 0 ]]; then
    printf "   ${RED}Errors  : %d${RESET}\n" "$errors"
else
    printf "   ${DIM}Errors  : %d${RESET}\n" "$errors"
fi
echo ""
