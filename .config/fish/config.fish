# environment variable
set -x KUBECONFIG $KUBECONFIG:~/.kube/config
set -x PATH /usr/local/bin/ $PATH
set -x PATH /Library/Frameworks/Python.framework/Versions/3.6/bin $PATH
set -x PATH $HOME/bin $PATH
set -x PATH $HOME/.nodebrew/current/bin $PATH
set -x HOMEBREW_CASK_OPTS --appdir=/Applications
set -g fish_user_paths "/usr/local/opt/gettext/bin" $fish_user_paths
set -x SUDO_PROMPT "[sudo] さっさとパスワード入れなさいよ、このバカ！ >"

# alias
alias ls='ls -FG'
alias ll='ls -lFG'
alias la='ls -alFG'
alias c='clear'
alias r='rmtrash'
alias sm='bass source ssm-peco.sh'
alias pc='pbcopy'
alias a2='docker run --rm -ti -e AWS_ACCESS_KEY_ID -v ~/.aws:/root/.aws -e AWS_SECRET_ACCESS_KEY -e AWS_SESSION_TOKEN amazon/aws-cli'
alias taa='terraform apply -auto-approve'
alias tda='terraform destroy -auto-approve'

function upgrade_aws_cli_v2
    set AWSCLIV2VERSION (aws --version)
    echo "Current version: $AWSCLIV2VERSION"
    echo ""
    curl -s "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
    sudo installer -pkg AWSCLIV2.pkg -target /
    rm AWSCLIV2.pkg
    echo ""
    echo "New version: $AWSCLIV2VERSION"
end

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
#set GHQ_SELECTOR peco

# bobthefish
set -g theme_display_git_master_branch yes
set -g theme_title_display_process yes
set -g theme_title_display_user yes
set -g theme_display_date no
set -g theme_display_cmd_duration no
set -g theme_color_scheme dracula

# direnv
direnv hook fish | source
set -x DIRENV_WARN_TIMEOUT 60s

# complete aws cli
complete --command aws --no-files --arguments '(begin; set --local --export COMP_SHELL fish; set --local --export COMP_LINE (commandline); aws_completer | sed \'s/ $//\'; end)'
