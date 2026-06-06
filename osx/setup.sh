#!/bin/bash
set -uo pipefail

# Resolve list.txt / cask_list.txt relative to this script, not the caller's cwd.
cd "$(dirname "$0")"

if ! command -v brew >/dev/null 2>&1; then
    echo "No brew found — installing Homebrew"
    # Download the official installer first, then run it, instead of piping a
    # network stream straight into a shell. (The old ruby/master URL is dead.)
    installer="$(mktemp)"
    curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o "$installer"
    /bin/bash "$installer"
    rm -f "$installer"
fi

echo "Update brew"
brew update

echo "Install formulas"
while IFS= read -r formula; do
    [ -z "$formula" ] && continue
    case "$formula" in \#*) continue ;; esac
    echo "==> brew install $formula"
    brew install "$formula" || echo "  ! failed: $formula"
done < list.txt

echo "Install casks"
while IFS= read -r formula; do
    [ -z "$formula" ] && continue
    case "$formula" in \#*) continue ;; esac
    echo "==> brew install --cask $formula"
    brew install --cask "$formula" || echo "  ! failed: $formula"
done < cask_list.txt
