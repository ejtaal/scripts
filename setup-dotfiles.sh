#!/bin/bash

# Just sets up dot files only :)

echo "  Installing dot files ..."

cd

for rcfile in ~/.bashrc ~/.zshrc; do
	if [ -L $rcfile ]; then
		echo "~/$(basename $rcfile) seems already installed:"
		ls -l $rcfile
	else
		mv -v $rcfile $rcfile.bak
		ln -s ~/scripts/shellrc $rcfile
		echo "New ~/$(basename $rcfile) installed"
	fi
done

pushd ~/scripts/dotfiles
for i in *; do
	if [ -f ~/."$i" -o -d ~/."$i" ]; then
		echo "~/.$i already found."
		if ! diff -q "$i" ~/."$i"; then
			echo "Diff: diff -u ~/.$i ~/scripts/dotfiles/$i"
			echo "Copy: cp -vf ~/scripts/dotfiles/$i ~/.$i"
		fi
	else
		cp -vR "$i" ~/."$i"
	fi
done
popd
