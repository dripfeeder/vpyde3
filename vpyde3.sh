#!/bin/bash

#title           :vim_python3_ide.sh
#description     :This script for vim-python3-ide local deployment
#author		 	 :Lucidyan
#date            :20150914
#version         :0.1a    
#usage		 	 :bash vim-python3-ide.sh

#note			 :Thanks for http://linux.cpms.ru/?p=8339
#==============================================================================

# Color-scheme
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo "\n${RED}Installing requirement packages${NC}"
sudo apt-get -y purge vim vim-*
sudo apt-get -y install python3 python3-dev python3-pip python3-jedi libncurses5-dev tmux git 

echo "\n${RED}Downloading Vim's sources from GitHub$(NC)"
mkdir -p ~/tmp
cd ~/tmp
git -C vim pull || git clone https://github.com/vim/vim.git vim
cd ~/tmp/vim/src/

echo "\n${RED}Configuring${NC}"

# System Bit Depth
BIT=$(getconf LONG_BIT);

# Find Pythons configurating dir for current version (todo Anyone's know better way? :)
VERSION="python"$(python3 --version | grep -oP "3(.|d)*$")
LIB_DIR=$(whereis "$VERSION" | grep -oP "/usr/lib/(\w|\d|\.)*")"/"
CONF_DIR=$(ls -d1 /usr/lib/python3.4/* | grep "config.*linux-gnu")

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
	--with-python3-config-dir=$CONF_DIR # example for troubleshooting: --with-python3-config-dir=/usr/lib/python3.4/config-3.4m-x86_64-linux-gnu
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
	--with-python3-config-dir=$CONF_DIR
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

