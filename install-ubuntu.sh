#!/bin/bash

sudo apt update
sudo apt install -y emacs
sudo apt install -y zsh
sudo apt install -y tmux
sudo apt install -y python3 python3-pip python3-venv

cp emacs/.emacs ~/.emacs

cp tmux/tmux.shared.conf ~/.tmux.shared.conf
cp tmux/tmux.conf.linux ~/.tmux.conf

zsh/ohmyzsh.sh
cp zsh/zshrc ~/.zshrc

exec zsh


