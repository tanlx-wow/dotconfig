


# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi



# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


# default setup
export EDITOR="nvim"

# # eza (better ls function)
# alias ls="eza --icons=always --git --color=always"
# # list all function
# alias ll="ls -lh"



# history setup
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

# bind key forward delete 
bindkey -e 
bindkey "^[[3~" delete-char

# completion using arrow keys (based on history)
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward



# ---- FZF -----

# Set up fzf key bindings and fuzzy completion
eval "$(fzf --zsh)"


# -- Use fd instead of fzf --

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}


# thefuck alias
eval $(thefuck --alias fk)



 # zoxide setup
 eval "$(zoxide init zsh)"
 alias cd="z"


# cargo bin 
export PATH="$HOME/.cargo/bin:$PATH"

# source the alias setup
[[ -f $HOME/.config/zsh/aliasrc.sh ]] && source $HOME/.config/zsh/aliasrc.sh

# fastfetch

(sleep 0.1 && fs) &

