#!/usr/bin/env bash

#title           :vim_python3_ide.sh
#description     :This script for vim-python3-ide local deployment (Ubuntu and MacOSX(alpha) support)
#author		 	 :Lucidyan
#date            :20160101
#version         :0.2a
#usage		 	 :bash vim-python3-ide.sh

#note			 :Thanks for http://linux.cpms.ru/?p=8339
#==============================================================================

# System Bit Depth
BIT=$(getconf LONG_BIT);
# Number of CPU's threads available
THREADS=$(getconf _NPROCESSORS_ONLN)

function ubuntu_install () {
    echo "\n${RED}Installing requirement packages${NC}"
    sudo apt-get -y purge vim vim-*
    sudo apt-get -y install python3 python3-dev python3-pip python3-jedi libncurses5-dev tmux git

    echo "\n${RED}Downloading Vim's sources from GitHub$(NC)"
    mkdir -p ~/tmp
    cd ~/tmp
    git -C vim pull || git clone https://github.com/vim/vim.git vim
    cd ~/tmp/vim/src/

    echo "\n${RED}Configuring${NC}"

    # Find Pythons configuration dir for current version
    PYTHON_FULL_VERSION="python"$(python3 --version | grep -o "3.*") # e.g. 3.5.1
    PYTHON_VERSION="python"$(python3 --version | grep -o "3.\d") # e.g. 3.5
    PYTHON_CONF_DIR=$(ls -d1 /usr/lib/python${PYTHON_VERSION}/* | grep "config.*linux-gnu")

    if [ "$BIT" = "64" ]
    then
    # for 64-bit version
        ./configure \
        --enable-perlinterp \
        --enable-python3interp \
        --enable-rubyinterp \
        --enable-cscope \
        --enable-gui=auto \
        --enable-gtk2-check \
        --enable-gnome-check \
        --with-features=huge \
        --enable-multibyte \
        --with-x \
        --with-python3-config-dir=${PYTHON_CONF_DIR} # example for troubleshooting: --with-python3-config-dir=/usr/lib/python3.5/config-3.5m-x86_64-linux-gnu
    else
    # for 32-bit version
    # todo check this conf
        ./configure \
        --enable-perlinterp \
        --enable-pythoninterp \
        --enable-rubyinterp \
        --enable-cscope \
        --enable-gui=auto \
        --enable-gtk2-check \
        --enable-gnome-check \
        --with-features=huge \
        --enable-multibyte \
        --with-x \
        --with-python3-config-dir=${PYTHON_CONF_DIR}
    fi
}

function mac_install () {
    echo "\n${RED}Installing requirement packages${NC}"
    brew tap beeftornado/rmtree && brew install brew-rmtree
    brew rmtree vim vim-*

    brew update
    brew install python3 tmux git
    curl https://bootstrap.pypa.io/get-pip.py | python3

    echo "\n${RED}Downloading Vim's sources from GitHub$(NC)"
    mkdir -p ~/tmp
    cd ~/tmp
    git -C vim pull || git clone https://github.com/vim/vim.git vim
    cd ~/tmp/vim/src/

    echo "\n${RED}Configuring${NC}"

    # Find Pythons configurating dir for current version (todo Anyone's know better way? :)
    PYTHON_FULL_VERSION="python"$(python3 --version | grep -o "3.*")
    PYTHON_VERSION="python"$(python3 --version | grep -o "3.\d")
    PYTHON_CONF_DIR="/usr/local/Cellar/python3/$(PYTHON_FULL_VERSION)/Frameworks/Python.framework/Versions/$(VERSION)/lib/python$(VERSION)/config-$(VERSION)m/"

    if [ "$BIT" = "64" ]; then
    # for 64-bit version
        ./configure \
        --enable-python3interp \
        --enable-cscope \
        --enable-gui=auto \
        --enable-gtk2-check \
        --enable-gnome-check \
        --with-features=huge \
        --enable-multibyte \
        --with-x \
        --with-python3-config-dir=${PYTHON_CONF_DIR} \
        --disable-darwin  # example for troubleshooting: --with-python3-config-dir=/usr/local/Cellar/python3/3.5.1/Frameworks/Python.framework/Versions/3.5/lib/python3.5/config-3.5m/
    else
    # for 32-bit version
    # todo check this conf
        ./configure \
        --enable-pythoninterp \
        --enable-cscope \
        --enable-gui=auto \
        --enable-gtk2-check \
        --enable-gnome-check \
        --with-features=huge \
        --enable-multibyte \
        --with-x \
        --with-python3-config-dir=${PYTHON_CONF_DIR} \
        --disable-darwin
    fi
}

function print_sys_info () {
    echo "\nDetect ${PLATFORM} Platform"
    echo "\n${BIT} Bit"
    echo "\n${THREADS} Threads"
}

if [ "$(uname)" == "Darwin" ]; then
    # Do something under Mac OS X platform
    PLATFORM='Mac'

    # Color-scheme
    RED=''
    GREEN=''
    NC=''
    print_sys_info
    mac_install
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    # Do something under GNU/Linux platform
    PLATFORM='Linux'

    # Color-scheme
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    NC='\033[0m'
    print_sys_info
    ubuntu_install
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
    # Do something under Windows NT platform
    echo "Windows is not supported by this script."
    exit 1
else
    echo "Your platform is not supported by this script."
    exit 1
fi

echo "\n${RED}Installing${NC}"
make
sudo make install

echo "\n${RED}Install wombat256 color scheme${NC}"
wget -P ~/.vim/colors https://raw.githubusercontent.com/Lucidyan/vpyde3/master/data/wombat256mod.vim

echo "\n${RED}Install requirement packages for vim's packages${NC}"
sudo pip3 install pyflakes pep8 pylint

echo "\n${RED}Install package manager for Vim (Vundle)${NC}"
git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim

echo "\n${RED}Replace .vimrc with custom version from GitHub${NC}"
wget -P ~/Downloads https://raw.githubusercontent.com/Lucidyan/vpyde3/master/data/.vimrc && mv .vimrc ~/.vimrc

echo "\n${RED}Install packages with Bundle${NC}"
vim +BundleInstall +qall

echo "\n${GREEN}Voi-la! Run your VIM IDE For Python in console :) ${NC}"