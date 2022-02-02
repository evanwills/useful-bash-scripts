#!/bin/sh

# ===============================================
# Make the aliases listed in a user's .bashrc file
# usable as a reference for available commands
# ===============================================


echo; echo;

grep alias $home/.bashrc | \
	grep ';' |
	grep -v '^# \?alias' | \
	sed 's/^alias \([a-z0-9]\+\)='"'\([^']\+\)';\?"'/\t\1  --  \2/ig' | \
	sed 's/^#\(.\+\)/\n\n -------------------------------------\n\1\n/ig' | \
	sed 's/;//g';

echo; echo;

