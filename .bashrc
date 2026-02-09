# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'
# # Helpful aliases
# alias c='clear'                                                        # clear terminal
# alias l='eza -lh --icons=auto'                                         # long list
alias ls='eza -1 --icons=auto'                                         # short list
alias ll='eza -lha --icons=auto --sort=name --group-directories-first' # long list all
# alias ld='eza -lhD --icons=auto'                                       # long list dirs
# alias lt='eza --icons=auto --tree'                                     # list folder as tree
# alias un='$aurhelper -Rns'                                             # uninstall package
# alias up='$aurhelper -Syu'                                             # update system/package/aur
# alias pl='$aurhelper -Qs'                                              # list installed package
# alias pa='$aurhelper -Ss'                                              # list available package
# alias pc='$aurhelper -Sc'                                              # remove unused cache
# alias po='$aurhelper -Qtdq | $aurhelper -Rns -'                        # remove unused packages, also try > $aurhelper -Qqd | $aurhelper -Rsu --print -
# alias vc='code'                                                        # gui code editor
# alias fastfetch='fastfetch --logo-type kitty'

# # Always mkdir a path (this doesn't inhibit functionality to make a single dir)
# alias mkdir='mkdir -p'

# unset -f command_not_found_handler # Uncomment to prevent searching for commands not found in package manager
alias d="docker"
alias dc="docker compose"
alias k="kubectl"

export EDITOR_CMD="nvim"
export EDITOR="$EDITOR_CMD" 
export VISUAL="$EDITOR_CMD"

export DFX_HSM_PIN=$(cat ~/.hsm-pin)
export HSM_PIN=$(cat ~/.hsm-pin)

export PATH="$HOME/.local/bin:$PATH"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

source "$HOME/.local/share/dfx/env"

source $HOME/.local/bin/env

# Setting up gpg and keys
gpg-agent --disable-scdaemon 2>/dev/null
export SSH_AUTH_SOCK=/run/user/1000/gnupg/S.gpg-agent.ssh

for key in ~/.ssh/id_*; do
    [[ -f "$key" && "$key" != *.pub ]] && ssh-add "$key" 2>/dev/null
done


. "$HOME/.local/share/../bin/env"
. "$XDG_DATA_HOME/dfx/env"
