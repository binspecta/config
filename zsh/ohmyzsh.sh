#!/bin/sh
# Install oh-my-zsh. Download the installer to a file first so a truncated
# download cannot execute as a partial script, and so it can be inspected
# before running, instead of piping the network stream straight into a shell.
set -e

installer="$(mktemp)"
curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -o "$installer"
sh "$installer" "" --unattended
rm -f "$installer"
