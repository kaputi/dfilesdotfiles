# Add deno completions to search path
if [[ ":$FPATH:" != *":/home/eduardo/.config/zsh/completions:"* ]]; then export FPATH="/home/eduardo/.config/zsh/completions:$FPATH"; fi
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

###################################zplug############################################

# source $ZPLUG_HOME/init.zsh

# zplug mafredri/zsh-async, from:github

# # Theme
# zplug "sindresorhus/pure", use:pure.zsh, from:github, as:theme
# zstyle :prompt:pure:git:stash show yes
# zstyle :prompt:pure:path color red
# zstyle :prompt:pure:git:branch color yellow
# zstyle :prompt:pure:prompt:success color green
# zstyle :prompt:pure:git:arrow blue

# # zplug "subnixr/minimal", as:theme
# # # MNML_NOMRAL_CHAR='-'
# # MNML_OK_COLOR=3

# # Autojump using z directory
# zplug "agkozak/zsh-z"

# # syntax
# zplug "zsh-users/zsh-syntax-highlighting", defer:2

# # autosugestion
# zplug "zsh-users/zsh-autosuggestions"

# # vim mode
# zplug "softmoth/zsh-vim-mode"

# # Install plugins if there are plugins that have not been installed
# if ! zplug check --verbose; then
#     printf "Install? [y/N]: "
#     if read -q; then
#         echo; zplug install
#     fi
# fi

# zplug load

# ZINIT =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit"

if [[ ! -d $ZINIT_HOME ]]; then
  mkdir -p $ZINIT_HOME
  git clone https://github.com/zdharma-continuum/zinit $ZINIT_HOME
fi

source $ZINIT_HOME/zinit.zsh

# prompt
zinit ice depth=1; zinit light romkatv/powerlevel10k
# syntax highlight
zinit light zsh-users/zsh-syntax-highlighting
# fzf
zinit light Aloxaf/fzf-tab
# autocomplete
zinit light zsh-users/zsh-completions
autoload -U compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
# autoSuggestions
zinit light zsh-users/zsh-autosuggestions

# Enable colors and change prompt:
autoload -U colors && colors

# History in cache directory:
mkdir -p ~/.cache/zsh
touch ~/.cache/zsh/history
HISTFILE=~/.cache/zsh/history
HISTSIZE=10000
SAVEHIST=10000
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Basic auto/tab complete:
# autoload -U compinit
# zstyle ':completion:*' menu select
# zmodload zsh/complist
# compinit
# _comp_options+=(globdots)		# Include hidden files.

# vi mode
# bindkey -v
# export KEYTIMEOUT=1

# Use vim keys in tab complete menu:
# bindkey -M menuselect 'h' vi-backward-char
# bindkey -M menuselect 'k' vi-up-line-or-history
# bindkey -M menuselect 'l' vi-forward-char
# bindkey -M menuselect 'j' vi-down-line-or-history
# bindkey -v '^?' backward-delete-char

# Change cursor shape for different vi modes.
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

# aliases

#dotfiles
# alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles.git/ --work-tree=$HOME'
# alias dotstatus='/usr/bin/git --git-dir=$HOME/.dotfiles.git/ --work-tree=$HOME status'
# alias dotlg='/usr/bin/git --git-dir=$HOME/.dotfiles.git/ --work-tree=$HOME lg'
# alias dotadd='/usr/bin/git --git-dir=$HOME/.dotfiles.git/ --work-tree=$HOME add -u'
# alias dotaddnew='/usr/bin/git --git-dir=$HOME/.dotfiles.git/ --work-tree=$HOME add'
# alias dotcommit='/usr/bin/git --git-dir=$HOME/.dotfiles.git/ --work-tree=$HOME commit'
# alias dotpush='/usr/bin/git --git-dir=$HOME/.dotfiles.git/ --work-tree=$HOME push'
# alias lazydotfiles='lazygit --git-dir=$HOME/.dotfiles.git/ --work-tree=$HOME'

#alias dfiles='/usr/bin/git --git-dir=$HOME/dddot --work-tree=$HOME'

# systemctl
alias ctl='sudo systemctl'
alias ctlstatus='sudo systemctl status'
alias ctlstart='sudo systemctl start'
alias ctlstop='sudo systemctl stop'
alias ctlrestart='sudo systemctl restart'

# better ls
alias ls='lsd --group-dirs first'
alias l='ls -l --blocks name,size,permission,user,group,date'
alias la='ls -a'
alias lla='ls -la --blocks name,size,permission,user,group,date'
alias lt='ls --tree --depth 3'
alias lta='ls --tree'
alias lls='/bin/ls'

#ssh conect to linode scumbags
# alias linode='ssh eduardo@lonighicode.com'

#ssh to cconecct to archserver
# alias archserver='ssh eduardo@176.58.110.157'

#mount alma smb
# alias start-library='cd /home/eduardo/alma/web-volume-viewer && yarn dev'
alias start-library='cd /home/eduardo/alma/web-volume-viewer && nvm use 14.21.3 && yarn startPy3'
# alias start-library-live='cd /home/eduardo/alma/web-volume-viewer && nvm use 14.20.0 && yarn dev-live'
alias start-library-live='cd /home/eduardo/alma/web-volume-viewer && nvm use 14.21.3 && yarn dev-live'
# alias start-viewer-local='cd /home/eduardo/alma/web-viewer && yarn start-local & kitty -d /home/eduardo/alma/backend-visor-node yarn start '
# dir size
alias dirsize='du -h -d 1 | sort -h'
alias sudodirsize='sudo du -h -d 1 | sort -h'

alias run-station='cd /home/eduardo/code/cmr/estacion/ && yarn start'
# alias run-station='cd /home/eduardo/code/electron/project-init/ && yarn start'

#pretty cat
alias ccat='/bin/cat'
alias cat='bat'

# exit vim style
alias :q='exit'
alias :Q='exit'
alias q='eixt'
alias Q='exit'

alias vim='nvim'
# alias nv='nvim'
# alias nv='~/nvim.appimage'
# alias nv='tvim'
# alias tv='tvim'
# alias nv='newvim'
alias nv='towervim'

# alias e='sw emacsclient -c'
# alias e='emacsclient -c -a emacs'

alias cp="cp -i"                          # confirm before overwriting something
# alias rm="rm -i"                          # confirm before removing
alias urm="/bin/rm -i"                          # confirm before removing
alias rrm="/bin/rm -i"                          # confirm before removing
alias rm="saferm.sh"                          # confirm before removing
alias df='df -h'                          # human-readable sizes
alias free='free -m'                      # show sizes in MB

alias wincmr='sudo mount -t cifs //192.168.1.89/Users/edu_l/Documents/CMR /home/eduardo/winCMR -o rw,user=edu_l,uid=1000,gid=1000'

# tmux
# alias t='tmux attach || tmux new'
# alias tt='tmux new'

# arrStack: inspect rootless docker as the arrstack user"
alias lazyarr='sudo -iu arrstack lazydocker'
alias arrcompose='sudo -iu arrstack docker compose -f /srv/arrstack/stack/docker-compose.yaml'

# git diff
alias gdd='git diff develop...HEAD | delta'
gdf() {
  local file
  file=$(git diff --name-only develop...HEAD | fzf --query="$1" --select-1 --exit-0) && git diff develop...HEAD -- "$file" | delta
}

# wrapper for ~/.local/bin/,j -- the script prints a path, this cds into it.
# `command ,j` reaches the real script instead of recursing into this function.
,j() {
  (($#)) && {
    command ,j "$@"
    return
  }
  local d
  d=$(command ,j) && [[ -n $d ]] && cd -- "$d"
}

# same wrapper as ,j, for the fuzzy picker: letters search, numbers pick rows.
# `,j2 --add` and friends are passed through to ,j, which owns the config.
,j2() {
  (($#)) && {
    command ,j2 "$@"
    return
  }
  local d
  d=$(command ,j2) && [[ -n $d ]] && cd -- "$d"
}

# jump to a cmr worktree: 0=estacion, 1=estacion-wt, N=estacion-wtN
# `,est 3` goes straight there; bare `,est` lists what exists and prompts
,est() {
  local base="$HOME/code/cmr" n="$1" d

  if [[ -z $n ]]; then
    # same palette as the claude statusline
    local i br red=$'\e[38;2;255;92;87m' yellow=$'\e[38;2;243;249;157m' reset=$'\e[0m'
    print -r -- "worktrees:"
    for d in $base/estacion(N/) $base/estacion-wt(N/) $base/estacion-wt<->(N/n); do
      d=${d%/}
      case $d in
        */estacion)    i=0 ;;
        */estacion-wt) i=1 ;;
        *)             i=${d##*-wt} ;;
      esac
      br=$(git -C $d symbolic-ref --quiet --short HEAD 2>/dev/null \
        || git -C $d rev-parse --short HEAD 2>/dev/null)
      print -r -- "  $i  ${red}${d}${reset}${br:+ ${yellow}(${br})${reset}}"
    done
    read "n?index: " || return 1
    [[ -z $n ]] && return 1
  fi

  if [[ $n != <-> ]]; then
    print -u2 -r -- ",est: '$n' is not a number"
    return 1
  fi

  case $n in
    0) d="$base/estacion" ;;
    1) d="$base/estacion-wt" ;;
    *) d="$base/estacion-wt$n" ;;
  esac

  if [[ ! -d $d ]]; then
    print -u2 -r -- ",est: no worktree $n ($d)"
    return 1
  fi

  cd -- "$d"
}

bindkey '\e[3~' delete-char
bindkey -M viins '\e[3~' delete-char
bindkey -M vicmd '\e[3~' delete-char


eval "$(fzf --zsh)"
# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

umask 022

[ -f "/home/eduardo/.ghcup/env" ] && . "/home/eduardo/.ghcup/env" # ghcup-env

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
