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
safe_link "$PROJECT_DIR/config/swaylock" "$XDG_CONFIG_HOME/swaylock"
safe_link "$PROJECT_DIR/config/kitty" "$XDG_CONFIG_HOME/kitty"
safe_link "$PROJECT_DIR/config/clipse" "$XDG_CONFIG_HOME/clipse"
safe_link "$PROJECT_DIR/config/xdg-desktop-portal" "$XDG_CONFIG_HOME/xdg-desktop-portal"
safe_link "$PROJECT_DIR/config/fastfetch" "$XDG_CONFIG_HOME/fastfetch"
safe_link "$PROJECT_DIR/config/noctalia" "$XDG_CONFIG_HOME/noctalia"
safe_link "$PROJECT_DIR/config/qt5ct" "$XDG_CONFIG_HOME/qt5ct"
safe_link "$PROJECT_DIR/config/qt6ct" "$XDG_CONFIG_HOME/qt6ct"
safe_link "$PROJECT_DIR/config/gtk-3.0" "$XDG_CONFIG_HOME/gtk-3.0"
safe_link "$PROJECT_DIR/config/gtk-4.0" "$XDG_CONFIG_HOME/gtk-4.0"

