# Add user configurations here
# For HyDE to not touch your beloved configurations,
# we added a config file for you to customize HyDE before loading zshrc
# Edit $ZDOTDIR/.user.zsh to customize HyDE before loading zshrc

#  Plugins 
# oh-my-zsh plugins are loaded  in $ZDOTDIR/.user.zsh file, see the file for more information

#  Aliases 
# Override aliases here in '$ZDOTDIR/.zshrc' (already set in .zshenv)

# # Helpful aliases
# alias c='clear'                                                        # clear terminal
# alias l='eza -lh --icons=auto'                                         # long list
# alias ls='eza -1 --icons=auto'                                         # short list
# alias ll='eza -lha --icons=auto --sort=name --group-directories-first' # long list all
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

# # Directory navigation shortcuts
# alias ..='cd ..'
# alias ...='cd ../..'
# alias .3='cd ../../..'
# alias .4='cd ../../../..'
# alias .5='cd ../../../../..'

# # Always mkdir a path (this doesn't inhibit functionality to make a single dir)
# alias mkdir='mkdir -p'

#  This is your file 
# Add your configurations here
# export EDITOR=nvim

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
source ~/.cargo/env
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

export PATH="$PATH:$HOME/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/lib/rustlib/x86_64-unknown-linux-gnu/bin/"

source "$HOME/.local/share/dfx/env"

source $HOME/.rye/env

gpg-agent --disable-scdaemon 2>/dev/null
export SSH_AUTH_SOCK=/run/user/1000/gnupg/S.gpg-agent.ssh

for key in ~/.ssh/id_*; do
    [[ -f "$key" && "$key" != *.pub ]] && ssh-add "$key" 2>/dev/null
done


export POCKET_IC_BIN=$(which pocket-ic)
export DRI_PRIME=1
source /usr/share/nvm/init-nvm.sh

export PATH=$PATH:~/.config/helix/helpers
export XDG_CONFIG_DIRS=$XDG_CONFIG_DIRS:~/.config
export PATH=$PATH:~/.dotnet/tools
export PATH=$PATH:~/.local/helpers

