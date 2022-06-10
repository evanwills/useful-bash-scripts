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

# thisDir="`dirname \"$0\"`"              # relative
# thisDirAbs="`( cd \"$MY_PATH\" && pwd )`"

# echo '$thisFile: '$thisDir
# echo '$thisFileAbs: '$thisDirAbs
# echo '$(pwd): '$(pwd)


# apps=(('regexMultiTool' 'Regex Multi-Tool') ('firingLogger' 'Firing logger') ('expensum' 'Expensum') ('wc-option-list-editor' 'Option list editor (WC)') ('wc-regex-input' 'Regex Input (WC)') ('regex-replace' 'Regex Find/Replace (WC)') ('drinking-chocolate' 'Drinking choclolate ratios (WC)') ('minecraft-sphere' 'Minecraft Sphere generator (WC)'));
# ffProfiles=('acuDev' 'ACU' 'supported' 'default' 'redux');

apps=(
	'regexMultiTool|Regex Multi-Tool'
	# 'firingLogger|Firing logger'
	'expensum|Expensum'
	'wc-option-list-editor|Option list editor (WC)'
	# 'wc-regex-input|Regex Input (WC)'
	# 'wc-regex-replace|Regex Find/Replace (WC)'
	# 'wc-drinking-chocolate|Drinking choclolate ratios (WC)'
	'wc-minecraft-sphere|Minecraft Sphere generator (WC)'
);

for i in "${apps[@]}";
do	repo=$(echo $i | sed 's/|.*$//')
	label=$(echo $i | sed 's/^[^|]\+|//')
	echo '$repo = '$repo;
	echo '$label = '$label
done