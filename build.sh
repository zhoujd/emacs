#!/bin/bash

SCRIPT_ROOT=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
BUILD_ROOT=$SCRIPT_ROOT/src/build

. /etc/os-release

EMACS_VER=27.2
EMACS_SRC=emacs-${EMACS_VER}
EMACS_PREFIX=/usr/local/${EMACS_SRC}
EMACS_OPT="--with-modules"

dep() {
    case $ID in
        ubuntu|debian )
            echo "Install on $ID"
            sudo apt update
            sudo apt install -y automake
            sudo apt install -y build-essential
            sudo apt install -y libxft-dev libotf-dev libgpm-dev imagemagick
            sudo apt install -y libxpm-dev libpng-dev libjpeg-dev libtiff-dev libgif-dev
            sudo apt install -y libxaw7-dev libncurses5-dev libgtk2.0-dev librsvg2-dev libgconf2-dev
            sudo apt install -y libm17n-dev libgnutls28-dev libselinux1-dev libdbus-1-dev
            ;;
        * )
            echo "Unsupport $ID"
            ;;
    esac
    echo "Install build deps done"
}

tool() {
    case $ID in
        ubuntu|debian )
            echo "Install on $ID"
            sudo apt install -y cscope
            sudo apt install -y texinfo
            sudo apt install -y markdown pandoc
            sudo apt install -y w3m
            sudo apt install -y silversearcher-ag ripgrep
            sudo apt install -y socat
            sudo apt install -y perl-doc
            sudo apt install -y ccls clangd
            ;;
        * )
            echo "Unsupport $ID"
            ;;
    esac
    echo "Install emacs tools done"
}

bin() {
    echo "Install emacs binary to /usr/bin/"
    sudo ln -sfvT /usr/local/${EMACS_SRC}/bin/emacs-${EMACS_VER} /usr/bin/emacs${EMACS_VER}
    sudo ln -sfvT /usr/bin/emacs${EMACS_VER} /usr/bin/emacs
    sudo ln -sfvT /usr/local/${EMACS_SRC}/bin/emacsclient /usr/bin/emacsclient
    sudo ln -sfvT /usr/local/${EMACS_SRC}/bin/etags /usr/bin/etags
    echo "Install bin done"
}

build() {
    mkdir -p $BUILD_ROOT
    pushd $BUILD_ROOT
    ../configure --prefix=${EMACS_PREFIX} ${EMACS_OPT}
    make -j4
    sudo make install
    popd
    echo "Build done"
}

clean() {
    pushd $SCRIPT_ROOT
    git reset --hard
    git clean -dfx
    popd
    echo "Clean done"
}

usage() {
    app=$(basename $0)
    cat <<EOF
Usage: $app {dep|-d|tool|-t|build|-b|bin|clean|-c|all|-a}
EOF
}

case $1 in
    dep|-d )
        dep
        ;;
    tool|-t )
        tool
        ;;
    build|-b )
        build
        bin
        ;;
    bin )
        bin
        ;;
    clean|-c )
        clean
        ;;
    all|-a )
        dep
        tool
        build
        bin
        clean
        ;;
    * )
        usage
        ;;
esac
