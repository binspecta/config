#!/bin/sh

git config --global user.email binspecta@gmail.com
git config --global user.name binspecta

git config --unset-all credential.helper
git config --global --unset-all credential.helper
git config --system --unset-all credential.helper
