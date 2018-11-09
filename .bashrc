# prompt
PS1="[\[\e[36m\]\u\[\e[0m\]@\[\e[32m\]\h \[\e[33m\]\W\[\e[0m\]]\$ "

# environment variable
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

# aliss
alias ls='ls -FG'
alias ll='ls -lFG'
alias la='ls -alFG'
alias c='clear'
alias r='rmtrash'
alias z='cd $(ghq root)/$(ghq list | peco)'
alias zz='hub browse $(ghq list | peco | cut -d "/" -f 2,3)'

# save current directory to bookmarks
touch ~/.sdirs
function s {
  cat ~/.sdirs | grep -v "export DIR_$1=" > ~/.sdirs1
  mv ~/.sdirs1 ~/.sdirs
  echo "export DIR_$1=$PWD" >> ~/.sdirs
}

# jump to bookmark
function g {
  source ~/.sdirs
  cd $(eval $(echo echo $(echo \$DIR_$1)))
}

# list bookmarks with dirnam
function l {
  source ~/.sdirs
  env | grep "^DIR_" | cut -c5- | grep "^.*="
}

# list bookmarks without dirname
function _l {
  source ~/.sdirs
  env | grep "^DIR_" | cut -c5- | grep "^.*=" | cut -f1 -d "="
}

# completion command for g
function _gcomp {
    local curw
    COMPREPLY=()
    curw=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=($(compgen -W '`_l`' -- $curw))
    return 0
}

# bind completion command for g to _gcomp
complete -F _gcomp g

# cut column
function col {
  awk -v col=$1 '{print $col}'
}
