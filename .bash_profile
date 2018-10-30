# Setting PATH for Python 3.6
# The original version is saved in .bash_profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.6/bin:${PATH}"
export PATH

export PATH=$HOME/bin:$PATH
export KUBECONFIG=$KUBECONFIG:~/.kube/config

if [ -f ~/.bashrc ] ; then
    . ~/.bashrc
fi

