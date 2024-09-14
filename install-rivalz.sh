#!/bin/bash

curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - && \
sudo apt install -y nodejs

npm i -g rivalz-node-cli

df -h


rivalz run


