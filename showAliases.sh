#!/bin/sh

userHome='/home/user';

echo; echo;

grep alias $userHome/.bashrc | grep ';' | grep -v '^# \?alias' | sed 's/^alias \([a-z0-9]\+\)='"'\([^']\+\)';\?"'/\t\1  --  \2/ig' | sed 's/^#\(.\+\)/\n\n -------------------------------------\n\1\n/ig' | sed 's/;//g';

echo; echo;
