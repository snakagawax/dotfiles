# environment variable
set -x KUBECONFIG $KUBECONFIG:~/.kube/config
set -x PATH /Library/Frameworks/Python.framework/Versions/3.6/bin $PATH
set -x PATH /usr/local/var/nodebrew/current/bin $PATH
set -x PATH $HOME/.nodebrew/current/bin $PATH
set -x HOMEBREW_CASK_OPTS --appdir=/Applications

# alias
alias ls='ls -FG'
alias ll='ls -lFG'
alias la='ls -alFG'
alias c='clear'
alias r='rmtrash'

# fisher
if not functions -q fisher
    set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
    curl https://git.io/fisher --create-dirs -sLo $XDG_CONFIG_HOME/fish/functions/fisher.fish
    fish -c fisher
end

# fish-peco_select_ghq_repository
function fish_user_key_bindings
  bind \cg peco_select_ghq_repository
  bind \cr peco_select_history
end

# bobthefish
set -g theme_display_git_master_branch yes
set -g theme_title_display_process yes
set -g theme_title_display_user yes
set -g theme_color_scheme dracula
