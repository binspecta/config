#!/bin/bash


if [ ! -e /usr/local/bin/brew ]
then
    echo "No brew, Please install brew first"
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

echo "Update brew"

brew update

echo "Install formulas"

formulas=`cat list.txt`

for formula in $formulas
do
    echo "==> brew install $formula"
    brew install $formula
done



cask_formulas=`cat cask_list.txt`


for formula in $cask_formulas
do
    echo "==> brew cask install $formula"
    brew cask install $formula
done
