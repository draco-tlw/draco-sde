# ~/.config/zsh/.zshrc

# --- 1. Interactive Startup (MUST run before p10k) ---
# Fastfetch renders here so Powerlevel10k doesn't intercept and break the Kitty image buffer or colors
if [[ $- == *i* ]]; then
    if command -v fastfetch &> /dev/null; then
        fastfetch --logo-type kitty --logo ~/.config/zsh/logos/skyrim-opacity-cropped.png --logo-padding-top 2 --logo-padding-left 4
    fi
fi

# --- 2. Load Powerlevel10k Instant Prompt ---
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# --- 3. Oh My Zsh Configuration ---
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
export EDITOR="code"

plugins=(
    git 
    sudo 
    zsh-autosuggestions 
    zsh-syntax-highlighting
)

# History & Autosuggestions config (must be before oh-my-zsh loads)
export HISTFILE="$ZDOTDIR/.zsh_history"
export HISTSIZE=10000
export SAVEHIST=10000
setopt SHARE_HISTORY # Instantly shares history across multiple open terminal tabs
export ZSH_AUTOSUGGEST_STRATEGY=(history completion) # Use both history and tab completions for suggestions

source $ZSH/oh-my-zsh.sh

# --- 4. Core Aliases ---
alias c='clear'
alias vc='code'
alias ..='cd ..'
alias ...='cd ../..'
alias mkdir='mkdir -p'

# Eza (better ls)
alias l='eza -lh --icons=auto'
alias ll='eza -lha --icons=auto --sort=name --group-directories-first'
alias ld='eza -lhD --icons=auto'
alias lt='eza --icons=auto --tree'

# Bat (better cat)
alias cat='bat --style=plain --paging=never --color auto'
alias -g -- --help='--help 2>&1 | bat --language=help --style=plain --paging=never --color always'

# Duf (better df)
alias df='duf'

# --- 5. FZF Custom Functions & Completions ---
_fuzzy_change_directory() {
    local selected_dir
    selected_dir=$(find . -maxdepth 7 \( -name .git -o -name node_modules -o -name .venv -o -name target -o -name .cache \) -prune -o -type d -print 2>/dev/null | fzf --height "80%" --layout=reverse --preview='ls -p {}' --preview-window=right:60% --cycle)
    [[ -n "$selected_dir" ]] && cd "$selected_dir"
}

_fuzzy_edit_search_file_content() {
    local selected_file
    selected_file=$(grep -irl "${1:-}" ./ | fzf --height "80%" --layout=reverse --cycle --preview-window right:60% --preview 'bat --color always --style=plain --paging=never {}')
    [[ -n "$selected_file" ]] && ${EDITOR:-vim} "$selected_file"
}

_fuzzy_edit_search_file() {
    local selected_file
    selected_file=$(find . -maxdepth 5 -type f 2>/dev/null | fzf --height "80%" --layout=reverse --preview-window right:60% --cycle)
    [[ -n "$selected_file" ]] && ${EDITOR:-vim} "$selected_file"
}

alias ffcd='_fuzzy_change_directory'
alias ffec='_fuzzy_edit_search_file_content'
alias ffe='_fuzzy_edit_search_file'

# Initialize FZF auto-completions and keybindings
if command -v fzf &> /dev/null; then
    eval "$(fzf --zsh)"
fi

# --- 6. Powerlevel10k Theme Config ---
# Load p10k config at the very end of the file
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
