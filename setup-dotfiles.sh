#!/bin/bash

# Just sets up dot files only :)

echo "  Installing dot files ..."

cd
if [ -L ~/.bashrc ]; then
	echo "Bashrc seems already installed:"
	ls -l ~/.bashrc
else
	mv -v ~/.bashrc ~/.bashrc.bak
	ln -s ~/scripts/bashrc ~/.bashrc
	echo "New bashrc installed"
fi

pushd ~/scripts/dotfiles
for i in *; do
	if [ -f ~/."$i" -o -d ~/."$i" ]; then
		echo "~/.$i already found."
	else
		cp -vR "$i" ~/."$i"
	fi
done
popd
