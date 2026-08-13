# ###############################################NODE###########################
# #source /usr/share/nvm/init-nvm.sh
#
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
#
# ###############################scales gtk3
# export GDK_SCALE=2
# #do not scale fonts
# export GDK_DPI_SCALE=0.5
#
# export QT_AUTO_SCREEN_SCALE_FACTOR=1
#
# export ELM_SCALE=1.5
# ################################################
# XDG_CONFIG_HOME="$HOME/.config"
# export XDG_CONFIG_HOME
# ##################################################
# export EDITOR=nvim
# export VISUAL=code
# export TERMINAL=alacritty
# # export BROWSER=google-chrome-stable
# export PAGER=more
# export WM=i3
# export OPENER=xdg-open
# export NNN_COLORS='1234'
# export NNN_TRASH=1
# export NNN_BMS='d:~/Documents;D:~/Downloads/;t:~/code/typescript'
# export NNN_FALLBACK_OPENER=xdg-open
# ##################ANDROID###############################
#
# export ANDROID_HOME=$HOME/Android/Sdk
# export PATH=$PATH:$ANDROID_HOME/emulator
# export PATH=$PATH:$ANDROID_HOME/tools
# export PATH=$PATH:$ANDROID_HOME/tools/bin
# export PATH=$PATH:$ANDROID_HOME/platform-tools
#
#
# ##############################################################################
#
# # export /bin to path
# # export PATH=$PATH:$HOME/bin
#
# # ruby
# export PATH=$PATH:$HOME/.gem/ruby/2.7.0/bin/
#
#
# source /usr/share/nvm/init-nvm.sh

# latest node fails in library unless this is set
NODE_OPTIONS=--openssl-legacy-provider

export PATH=$PATH:$HOME/.local/bin
export ZPLUG_HOME=$HOME/.config/zplug

# export EDITOR="nv"
export EDITOR="tv2"

# zk dir
export ZK_NOTEBOOK_DIR=$HOME/Documents/zk

# go
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# flutter
export CHROME_EXECUTABLE=google-chrome-stable
export PATH=$PATH:$HOME/development/flutter/bin

#deno
export DENO_INSTALL="$HOME/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

# nix
export PATH="$HOME/.nix-profile/bin:$PATH"

# ssh-agent
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

export CLAUDE_CODE_DISABLE_MOUSE_CLICKS=1
