#!/bin/sh

echo "Setting up your new system, just sit back and relax..."

mv -v ~/.bashrc ~/.bashrc.bak
ln -s ~/scripts/bashrc ~/.bashrc

echo "New bash installed"
