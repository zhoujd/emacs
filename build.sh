#!/bin/bash

SCRIPT_ROOT=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
SRC_ROOT=$SCRIPT_ROOT/src
BUILD_ROOT=$SRC_ROOT/build

. /etc/os-release

EMACS_VER=27.2
EMACS_SRC=emacs-${EMACS_VER}
EMACS_PREFIX=/usr/local/${EMACS_SRC}
EMACS_OPT=(
    --with-modules
    --with-x-toolkit=lucid
)

install_dep() {
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

install_tool() {
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
            sudo apt install -y ccls
            ;;
        * )
            echo "Unsupport $ID"
            ;;
    esac
    echo "Install emacs tools done"
}

install_bin() {
    target=/usr/bin
    echo "Install emacs bin to $target"
    sudo ln -sfvT $EMACS_PREFIX/bin/emacs-${EMACS_VER} $target/emacs${EMACS_VER}
    sudo ln -sfvT $target/emacs${EMACS_VER} $target/emacs
    echo "Install emacs tool to $target"
    sudo ln -sfvT $EMACS_PREFIX/bin/emacsclient $target/emacsclient
    sudo ln -sfvT $EMACS_PREFIX/bin/etags $target/etags
    echo "Install bin done"
}

build() {
    echo "Build run autogen.sh"
    pushd $SRC_ROOT
    ./autogen.sh
    popd
    echo "Build emacs-${EMACS_VER}"
    mkdir -p $BUILD_ROOT
    pushd $BUILD_ROOT
    $SRC_ROOT/configure --prefix=${EMACS_PREFIX} ${EMACS_OPT[@]}
    make -j8
    sudo make install
    install_bin
    popd
    echo "Build done"
}

clean() {
    pushd $SCRIPT_ROOT
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
        install_dep
        ;;
    tool|-t )
        install_tool
        ;;
    build|-b )
        build
        ;;
    bin )
        install_bin
        ;;
    clean|-c )
        clean
        ;;
    all|-a )
        install_dep
        install_tool
        build
        clean
        ;;
    * )
        usage
        ;;
esac
