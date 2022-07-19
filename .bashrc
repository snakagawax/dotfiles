# prompt
PS1="[\[\e[36m\]\u\[\e[0m\]@\[\e[32m\]\h \[\e[33m\]\W\[\e[0m\]]\$(__git_ps1 [%s])\[\033[00m\]\$ "

# environment variable
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
export PATH="/usr/local/opt/gettext/bin:$PATH"
export SUDO_PROMPT="[sudo] さっさとパスワード入れなさいよ、このバカ！ > "

# complete
complete -C '/usr/local/bin/aws_completer' aws

# aliss
alias ls='ls -FG'
alias ll='ls -lFG'
alias la='ls -alFG'
alias c='clear'
alias r='rmtrash'
alias z='cd $(ghq root)/$(ghq list | peco)'
alias zz='hub browse $(ghq list | peco | cut -d "/" -f 2,3)'
#alias aa='op signin classmethod  --output=raw | op get totp -v "AWS" | pbcopy'

function ghql() {
  local selected_file=$(ghq list --full-path | peco --query "$LBUFFER")
  if [ -n "$selected_file" ]; then
    if [ -t 1 ]; then
      echo ${selected_file}
      cd ${selected_file}
      pwd
    fi
  fi
}

bind -x '"\201": ghql'
bind '"\C-g":"\201\C-m"'

# direnv setting
eval "$(direnv hook bash)"
