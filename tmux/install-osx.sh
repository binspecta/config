#!/bin/sh

brew install python
ln -s /usr/local/bin/python2 /usr/local/bin/python
ln -s /usr/local/bin/pip2 /usr/local/bin/pip
pip install powerline-status

brew install reattach-to-user-namespace

cp tmux.shared.conf ~/.tmux.shared.conf
cp tmux.conf.osx ~/.tmux.conf

cp itunes* /usr/local/bin/
