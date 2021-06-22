#!/bin/sh

echo;
echo 'Testing something in a (Bash) shell script';
echo;

# path='src/Project/ACUPublic/ACU.Static/scss/pattern-lib/atoms/_chsl-mask.blah.scss';
# echo '$path: '$path

# fileName=$(echo $path | sed 's/^\([^\/]\+\/\)\+//');
# echo '$fileName: '$fileName

# fileType=$(echo $fileName | sed 's/^\([^\.]\+\.\)\+//');
# echo '$fileType: '$fileType

# path='src/Project/ACUPublic/ACU.Static/scss/pattern-lib/atoms/';
# find $path -maxdepth 0 -empty -exec echo {} is empty. \;
# find $path -type d -empty -exec command1 arg1 {} \;


# transform first char to uppercse

# str='chickenMan'
# echo '$str = '$str
# str=${str,}
# echo '$str = '$str
# str=${str^}
# echo '$str = '$str


# Better evanh

grep alias /c/Users/evwills/.bashrc | grep ';' | grep -v '^# \?alias' | sed 's/^alias \([a-z0-9]\+\)='"'\([^']\+\)';\?"'/\t\1  --  \2/ig' | sed 's/^#\(.\+\)/\n\n -------------------------------------\n\1\n/ig' | sed 's/;//g';

