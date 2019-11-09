#!/bin/bash

OS=$(uname)

alias cp='cp -v'
SELF=$(basename $0)

_pwdcheck () {
if [[ $(basename ${PWD}) != public_dotfiles ]]; then
    echo "Script must be run in public_dotfiles root directory"
    exit 2
fi
}

_install () {
    ln -s ${PWD}/.init_bash ${HOME}/.init_bash
    ln -s ${PWD}/.functions.bash ${HOME}/.functions.bash
    ln -s ${PWD}/.tmux.conf ${HOME}/.tmux.conf
    ln -s ${PWD}/.Xdefaults ${HOME}/.Xdefaults

    if [[ ! -d ${HOME}/.config/nvim/init.vim ]]; then
        mkdir -p ${HOME}/.config/nvim/init.vim
        ln -s ${PWD}/init.vim ${HOME}/.config/nvim/init.vim
    else
        ln -s ${PWD}/init.vim ${HOME}/.config/nvim/init.vim
    fi
}

_install_OBSD () {
    ln -s ${PWD}/.init_bash ${HOME}/.init_bash
    ln -s ${PWD}/.functions.bash ${HOME}/.functions.bash
    ln -s ${PWD}/.tmux.conf ${HOME}/.tmux.conf
    ln -s ${PWD}/.Xdefaults ${HOME}/.Xdefaults
    ln -s ${PWD}/.xinitrc ${HOME}/.xinitrc

    if [[ ! -d ${HOME}/.config/nvim/init.vim ]]; then
        mkdir -p ${HOME}/.config/nvim/init.vim
        ln -s ${PWD}/init.vim ${HOME}/.config/nvim/init.vim
    else
        ln -s ${PWD}/init.vim ${HOME}/.config/nvim/init.vim
    fi

    cp ${PWD}/Xresources /etc/X11/xenodm/Xresources
    cp ${PWD}/Xsetup_0 /etc/X11/xenodm/Xsetup_0
    cp ${PWD}/.x

}

case $OS in 
    Linux)
        _pwdcheck
        _install
        ;;
    OpenBSD)
        _pwdcheck
        _install_OBSD
        ;;
esac
