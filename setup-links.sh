#!/usr/bin/env bash
#
# Symlinks skills, agents, and settings from this repo into AI coding tool
# config directories. The repo is the source of truth.
#
# Interactive multi-select for tools and skills, or --all for everything
# (non-interactive). Link behavior:
#   - missing target            -> create symlink
#   - symlink into this repo    -> repaired to the current repo path
#   - symlink elsewhere         -> skipped
#   - real file (settings only) -> backed up to <name>.pre-repo.bak, then linked
#   - real file/dir (skills)    -> skipped (merge into the repo manually first)
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/skills"
AGENTS_DIR="$SCRIPT_DIR/agents"
EXTENSIONS_DIR="$SCRIPT_DIR/extensions"
SETTINGS_DIR="$SCRIPT_DIR/settings"

ALL_MODE=0
[[ "${1:-}" == "--all" ]] && ALL_MODE=1

# ── Tool definitions ────────────────────────────────────────────────
declare -A TOOL_PATHS
TOOL_PATHS=(
    ["Copilot CLI"]="$HOME/.copilot/skills"
    ["Claude Code"]="$HOME/.claude/skills"
    ["Pi"]="$HOME/.pi/agent/skills"
    ["OpenCode"]="$HOME/.config/opencode/skills"
)
TOOL_ORDER=("Copilot CLI" "Claude Code" "Pi" "OpenCode")

# ── Discover skills (skills/* dirs containing a SKILL.md) ──────────
SKILLS=()
while IFS= read -r -d '' dir; do
    name="$(basename "$dir")"
    [[ -f "$dir/SKILL.md" ]] || continue
    SKILLS+=("$name")
done < <(find "$SKILLS_DIR" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

if [[ ${#SKILLS[@]} -eq 0 ]]; then
    echo "❌ No skill folders found under skills/."
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
multi_select() {
    local -n _result=$1
    local title="$2"
    shift 2
    local items=("$@")
    local count=${#items[@]}

    local selected=()
    for (( i=0; i<count; i++ )); do selected+=(1); done
    local cursor=0

    printf '\e[?25l'
    trap 'printf "\e[?25h"' RETURN

    echo ""
    printf "  ${CYAN}%s${RESET}\n" "$title"
    printf "  ${DIM}(↑/↓ navigate, Space toggle, a select all, n select none, Enter confirm)${RESET}\n\n"

    render() {
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
        IFS= read -rsn1 key
        case "$key" in
            $'\x1b')
                read -rsn2 seq
                case "$seq" in
                    '[A') (( cursor > 0 )) && (( cursor-- )) ;;
                    '[B') (( cursor < count-1 )) && (( cursor++ )) ;;
                esac
                ;;
            ' ')
                if [[ ${selected[$cursor]} -eq 1 ]]; then
                    selected[$cursor]=0
                else
                    selected[$cursor]=1
                fi
                ;;
            'a'|'A') for (( i=0; i<count; i++ )); do selected[$i]=1; done ;;
            'n'|'N') for (( i=0; i<count; i++ )); do selected[$i]=0; done ;;
            '') break ;;
        esac
        render "redraw"
    done

    echo ""

    _result=()
    for (( i=0; i<count; i++ )); do
        [[ ${selected[$i]} -eq 1 ]] && _result+=("${items[$i]}")
    done
}

created=0
repaired=0
uptodate=0
skipped=0
errors=0

# link_repo <link_path> <target_path> <label> <backup:0|1>
link_repo() {
    local link_path="$1" target_path="$2" label="$3" backup="${4:-0}"

    if [[ -L "$link_path" ]]; then
        local current
        current="$(readlink "$link_path")"
        if [[ "$current" == "$target_path" ]]; then
            printf "   ${DIM}⏭  %s (already linked)${RESET}\n" "$label"
            (( uptodate++ )) || true
            return
        fi
        if [[ "$current" == "$SCRIPT_DIR"* ]]; then
            rm "$link_path"
            ln -s "$target_path" "$link_path"
            printf "   ${GREEN}🔧 %s → repaired (stale repo link)${RESET}\n" "$label"
            (( repaired++ )) || true
            return
        fi
        printf "   ${YELLOW}⏭  %s (symlink to another location — skipped)${RESET}\n" "$label"
        (( skipped++ )) || true
        return
    fi

    if [[ -e "$link_path" ]]; then
        if [[ "$backup" -eq 1 ]]; then
            mv "$link_path" "$link_path.pre-repo.bak"
            ln -s "$target_path" "$link_path"
            printf "   ${GREEN}✅ %s → linked (original saved as .pre-repo.bak)${RESET}\n" "$label"
            (( created++ )) || true
        else
            printf "   ${YELLOW}⚠  %s (real file/dir in the way — merge into repo, then re-run)${RESET}\n" "$label"
            (( skipped++ )) || true
        fi
        return
    fi

    if ln -s "$target_path" "$link_path" 2>/dev/null; then
        printf "   ${GREEN}✅ %s → linked${RESET}\n" "$label"
        (( created++ )) || true
    else
        printf "   ${RED}❌ %s — symlink failed${RESET}\n" "$label"
        (( errors++ )) || true
    fi
}

# ── Step 1: Select tools ───────────────────────────────────────────
selected_tools=()
if [[ $ALL_MODE -eq 1 ]]; then
    selected_tools=("${TOOL_ORDER[@]}")
else
    multi_select selected_tools "Select target tools:" "${TOOL_ORDER[@]}"
fi

if [[ ${#selected_tools[@]} -eq 0 ]]; then
    printf "${YELLOW}⚠  No tools selected. Exiting.${RESET}\n"
    exit 0
fi

tool_selected() {
    local t
    for t in "${selected_tools[@]}"; do
        [[ "$t" == "$1" ]] && return 0
    done
    return 1
}

# ── Step 2: Select skills ──────────────────────────────────────────
selected_skills=()
if [[ $ALL_MODE -eq 1 ]]; then
    selected_skills=("${SKILLS[@]}")
else
    multi_select selected_skills "Select skills to link:" "${SKILLS[@]}"
fi

# ── Step 3: Link skills ────────────────────────────────────────────
for tool in "${selected_tools[@]}"; do
    [[ ${#selected_skills[@]} -eq 0 ]] && break
    target_dir="${TOOL_PATHS[$tool]}"
    printf "\n${CYAN}📁 %s skills → %s${RESET}\n" "$tool" "$target_dir"
    mkdir -p "$target_dir"

    for skill in "${selected_skills[@]}"; do
        link_repo "$target_dir/$skill" "$SKILLS_DIR/$skill" "$skill" 0
    done
done

# ── Step 4: Link agents ────────────────────────────────────────────
# Claude Code: ~/.claude/agents/<name>.md
# Copilot CLI: ~/.copilot/agents/<name>.agent.md
if [[ -d "$AGENTS_DIR" ]]; then
    for agent_file in "$AGENTS_DIR"/*.md; do
        [[ -e "$agent_file" ]] || continue
        agent_name="$(basename "$agent_file" .md)"
        [[ "$agent_name" == "README" ]] && continue

        if tool_selected "Claude Code"; then
            mkdir -p "$HOME/.claude/agents"
            link_repo "$HOME/.claude/agents/$agent_name.md" "$agent_file" "claude: $agent_name.md" 0
        fi
        if tool_selected "Copilot CLI"; then
            mkdir -p "$HOME/.copilot/agents"
            link_repo "$HOME/.copilot/agents/$agent_name.agent.md" "$agent_file" "copilot: $agent_name.agent.md" 0
        fi
    done
fi

# ── Step 4b: Link Pi extensions (pi's analog to hooks) ─────────────
# Pi extensions are TypeScript modules in ~/.pi/agent/extensions/. Each
# top-level .ts file or extension directory in the repo's extensions/ is
# linked individually so pi can hot-reload them with /reload.
if tool_selected "Pi" && [[ -d "$EXTENSIONS_DIR" ]]; then
    target_dir="$HOME/.pi/agent/extensions"
    printf "\n${CYAN}🧩 Pi extensions → %s${RESET}\n" "$target_dir"
    mkdir -p "$target_dir"
    for ext in "$EXTENSIONS_DIR"/*; do
        [[ -e "$ext" ]] || continue
        name="$(basename "$ext")"
        [[ "$name" == "README.md" ]] && continue
        link_repo "$target_dir/$name" "$ext" "$name" 0
    done
fi

# ── Step 5: Link settings (real files backed up to .pre-repo.bak) ──
printf "\n${CYAN}⚙  Settings${RESET}\n"
if tool_selected "Claude Code"; then
    [[ -f "$SETTINGS_DIR/claude/settings.json" ]] && link_repo "$HOME/.claude/settings.json" "$SETTINGS_DIR/claude/settings.json" "~/.claude/settings.json" 1
    [[ -f "$SETTINGS_DIR/claude/CLAUDE.md" ]]     && link_repo "$HOME/.claude/CLAUDE.md"     "$SETTINGS_DIR/claude/CLAUDE.md"     "~/.claude/CLAUDE.md" 1
    [[ -d "$SETTINGS_DIR/shared" ]]               && link_repo "$HOME/.claude/shared"        "$SETTINGS_DIR/shared"               "~/.claude/shared" 1
fi
if tool_selected "Copilot CLI"; then
    [[ -f "$SETTINGS_DIR/copilot/settings.json" ]]         && link_repo "$HOME/.copilot/settings.json"         "$SETTINGS_DIR/copilot/settings.json"         "~/.copilot/settings.json" 1
    [[ -f "$SETTINGS_DIR/copilot/copilot-instructions.md" ]] && link_repo "$HOME/.copilot/copilot-instructions.md" "$SETTINGS_DIR/copilot/copilot-instructions.md" "~/.copilot/copilot-instructions.md" 1
    [[ -d "$SETTINGS_DIR/shared" ]]                          && link_repo "$HOME/.copilot/shared"                  "$SETTINGS_DIR/shared"                           "~/.copilot/shared" 1
fi
if tool_selected "Pi"; then
    # Pi's settings.json is deliberately NOT linked: pi writes machine state
    # (e.g. lastChangelogVersion) into it, which would churn in git.
    mkdir -p "$HOME/.pi/agent"
    [[ -f "$SETTINGS_DIR/pi/AGENTS.md" ]] && link_repo "$HOME/.pi/agent/AGENTS.md" "$SETTINGS_DIR/pi/AGENTS.md" "~/.pi/agent/AGENTS.md" 1
    [[ -d "$SETTINGS_DIR/shared" ]]       && link_repo "$HOME/.pi/agent/shared"   "$SETTINGS_DIR/shared"       "~/.pi/agent/shared" 1
fi

# ── Summary ─────────────────────────────────────────────────────────
printf "\n${DIM}── Summary ───────────────────────────────${RESET}\n"
printf "   ${GREEN}Created   : %d${RESET}\n" "$created"
printf "   ${GREEN}Repaired  : %d${RESET}\n" "$repaired"
printf "   ${DIM}Up to date: %d${RESET}\n" "$uptodate"
printf "   ${YELLOW}Skipped   : %d${RESET}\n" "$skipped"
if [[ $errors -gt 0 ]]; then
    printf "   ${RED}Errors    : %d${RESET}\n" "$errors"
else
    printf "   ${DIM}Errors    : %d${RESET}\n" "$errors"
fi
echo ""
