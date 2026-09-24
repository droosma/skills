#!/usr/bin/env bash
set -euo pipefail

manifest="${1:?plugin manifest is required}"
tool="${2:?target tool is required}"
dry_run="${3:-}"

if ! command -v node >/dev/null 2>&1; then
    echo "Node.js is required to read plugin manifests." >&2
    exit 1
fi

IFS=$'\x1f' read -r name mode command marketplace_source marketplace_match plugin installed_match source skill yes < <(
    node "$(dirname "$0")/plugin-manifest.mjs" fields "$manifest" "$tool"
)

if [[ -z "$mode" ]]; then
    printf "   - %s: %s is not supported\n" "$name" "$tool"
    exit 0
fi

case "$mode" in
    marketplace-plugin)
        install_args=(plugin install "$plugin")
        [[ "$yes" == "true" ]] && install_args+=(-y)
        if [[ "$dry_run" == "--dry-run" ]]; then
            printf "   - %s for %s: %s plugin marketplace add %s; %s %s\n" \
                "$name" "$tool" "$command" "$marketplace_source" "$command" "${install_args[*]}"
            exit 0
        fi

        command -v "$command" >/dev/null 2>&1 || {
            echo "Required command '$command' was not found." >&2
            exit 1
        }
        marketplaces="$("$command" plugin marketplace list 2>&1)"
        if [[ "$marketplaces" != *"$marketplace_match"* ]]; then
            "$command" plugin marketplace add "$marketplace_source"
        fi
        plugins="$("$command" plugin list 2>&1)"
        if [[ "$plugins" == *"$installed_match"* ]]; then
            printf "   - %s: already installed for %s\n" "$name" "$tool"
            exit 0
        fi
        "$command" "${install_args[@]}"
        printf "   + %s: installed for %s\n" "$name" "$tool"
        ;;
    pi-package)
        if [[ "$dry_run" == "--dry-run" ]]; then
            printf "   - %s for Pi: pi install %s\n" "$name" "$source"
            exit 0
        fi

        command -v pi >/dev/null 2>&1 || {
            echo "Required command 'pi' was not found." >&2
            exit 1
        }
        installed_packages="$(pi list 2>&1)"
        if [[ "$installed_packages" == *"$installed_match"* ]]; then
            printf "   - %s: already installed for Pi\n" "$name"
            exit 0
        fi
        pi install "$source"
        printf "   + %s: installed for Pi\n" "$name"
        ;;
    opencode-plugin)
        config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
        config_path="$config_dir/opencode.json"
        if [[ "$dry_run" == "--dry-run" ]]; then
            printf "   - %s for OpenCode: add '%s' to %s\n" "$name" "$plugin" "$config_path"
            exit 0
        fi

        mkdir -p "$config_dir"
        result="$(node "$(dirname "$0")/plugin-manifest.mjs" add-opencode "$config_path" "$plugin")"
        if [[ "$result" == "unchanged" ]]; then
            printf "   - %s: already configured for OpenCode\n" "$name"
        else
            printf "   + %s: configured for OpenCode\n" "$name"
        fi
        ;;
    skill-fallback)
        printf "   - %s: %s uses the portable '%s' skill\n" "$name" "$tool" "$skill"
        ;;
    *)
        echo "Unknown plugin mode '$mode' in $manifest." >&2
        exit 1
        ;;
esac
