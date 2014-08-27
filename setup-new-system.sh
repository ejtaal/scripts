#!/bin/sh

echo "Setting up your new system, just sit back and relax..."

mv -v ~/.bashrc ~/.bashrc.bak
ln -s ~/scripts/bashrc ~/.bashrc

echo "New bash installed"



if [ -x /usr/bin/yum ]; then
	PKGS="vim htop nmap git gitk system-config-lvm"
	yum install $PKGS
fi
