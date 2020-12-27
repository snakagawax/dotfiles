# Setting PATH for Python 3.6
# The original version is saved in .bash_profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.6/bin:${PATH}"
PATH=$HOME/.nodebrew/current/bin:$PATH
export PATH

export KUBECONFIG=$KUBECONFIG:~/.kube/config

if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi

if [ -f ~/.bashrc ] ; then
    . ~/.bashrc
fi

