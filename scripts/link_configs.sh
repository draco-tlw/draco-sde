#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)" 
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

safe_link() {
    local src="$1"
    local target="$2"

    src="${src%/}"
    target="${target%/}"

    if [[ ! -e "$src" ]]; then
        echo "[ERROR]  Source path does not exist: $src" >&2
        return 1
    fi

    if [[ -L "$target" && "$src" -ef "$target" ]]; then
        echo "[SKIP]   $target -> $src (already up to date)"
        return 0
    fi

    if [[ -L "$target" ]]; then
        echo "[RELINK] Removing stale or incorrect symlink at $target"
        rm -f "$target"
        
    elif [[ -e "$target" ]]; then
        local timestamp
        timestamp="$(date +%Y%m%d_%H%M%S)"
        local backup_path="${target}.bak.${timestamp}"
        
        echo "[BACKUP] Moving existing path $target -> $backup_path"
        mv "$target" "$backup_path"
    fi

    mkdir -p "$(dirname "$target")"

    echo "[LINK]   $target -> $src"
    ln -s "$src" "$target"
}


echo "=> Symlinking configs..."

safe_link "$PROJECT_DIR/config/sway" "$XDG_CONFIG_HOME/sway"
safe_link "$PROJECT_DIR/config/mako" "$XDG_CONFIG_HOME/mako"
safe_link "$PROJECT_DIR/config/rofi" "$XDG_CONFIG_HOME/rofi"
safe_link "$PROJECT_DIR/config/clipse" "$XDG_CONFIG_HOME/clipse"
