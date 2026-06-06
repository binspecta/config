#!/bin/sh
set -e

if [ -z "$1" ]; then
    echo "usage: $0 <commit message>" >&2
    exit 1
fi

# Stage all tracked changes (including dotfiles and deletions). 'git add *'
# relied on shell globbing, which skips dotfiles and can misfire on filenames.
git add -A
git commit -m "$1"
git push origin master
