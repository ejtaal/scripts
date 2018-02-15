#!/bin/sh

for lang in en nl; do
	for enc in latin1 utf-8; do
		wget http://ftp.vim.org/vim/runtime/spell/$lang.$enc.spl
	done
done
