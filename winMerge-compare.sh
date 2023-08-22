#!/bin/sh

# -------------------------------------------------------------------
# Launch WinMerge if there are any differences between the two
# (or three) files supplied.
#
# If one file exists and either of the other files do not exist,
# create the missing file(s) where they are expected to be.
#
# Expects 5 arguments:
# * Left directory path
# * Middle directory path
# * Right directory path. If omitted, right dir path should be "XX"
# * Relative directory path to file. If omitted, rel dir path should be "XX"
# * File name. Name of file to be compared in all directories.
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# WinMerge CLI arguents used below:
#
# -s (/s) Limits WinMerge windows to a single instance. For example,
#         if WinMerge is already running, a new compare opens in the
#         same instance. Without this parameter, multiple windows are
#         allowed: depending on other settings, a new compare might
#         open in the existing window or in a new window.
#
# -e (/e) Enables you to close WinMerge with a single Esc key press.
#         This is useful when you use WinMerge as an external compare
#         application: you can close WinMerge quickly, like a dialog.
#         Without this parameter, you might have to press Esc
#         multiple times to close all its windows.
#
# --fl (/fl) Sets focus to the left side at startup.
#
# --ignoreeol (/ignoreeol) Ignore end-of-line character differences
#         (I think. Not yet documented)
#
# For more info on WinMerge CLI arguments, see
#   https://manual.winmerge.org/en/Command_line.html
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# GNU diff arguents used below:
#
# -q Report only whether the files differ, not the details of the differences.
#    See [Summarizing Which Files Differ](https://www.gnu.org/software/diffutils/manual/html_node/Brief.html).
#
# -Z Ignore white space at line end.
#    See [Suppressing Differences in Blank and Tab Spacing](https://www.gnu.org/software/diffutils/manual/html_node/White-Space.html).
#
# For more info on GNU diff arguments, see
#   https://www.gnu.org/software/diffutils/manual/html_node/diff-Options.html
# -------------------------------------------------------------------



# Check if both sides of a pair of files exist
# If one is missing and the other is not missing, copy the existing
# one to the missing file path
#
# @param $1 - first file path
# @param $2 - second file path
function copyMissingPair () {
	first="$1";
	second="$2";

	if [ -z "$first" ]
	then	# Can't copy if first path is empty
		return;
	fi;

	if [ -z "$second" ]
	then	# Can't copy if secon path is empty
		return;
	fi;

	if [ -f "$first" ]
	then	if [ -f "$second" ]
		then	# Both files already exist
			return;
		fi
	fi;

	if [ -f "$first" ]
	then	if [ ! -f "$second" ]
		then	# Copied first file to second file path
			cp -v "$first" "$second";
			return;
		fi;
	else 	if [ ! -f "$first" ]
		then	if [ -f "$second" ]
			then	# Copied second file to first file path
				cp -v "$second" "$first"
				return;
			fi
		fi
	fi;

	# Could not copy files
}


lRoot="$1";
mRoot="$2";
rRoot="$3";
relPath="$4";
file="$5";

if [ "$rRoot" == 'XX' ]
then	rRoot='';
fi

if [ "$relPath" != 'XX' ]
then	relPath='\\'"$relPath"'\\';
else	relPath='\\';
fi;

l=$lRoot$relPath$file;
m=$mRoot$relPath$file;
r='';

if [ ! -z "$rRoot" ]
then	r=$rRoot$relPath$file;
fi

copyMissingPair "$l" "$m";
copyMissingPair "$l" "$r";
copyMissingPair "$m" "$r";

# echo "\$lRoot: '$lRoot'";
# echo "\$mRoot: '$mRoot'";
# echo "\$rRoot: '$rRoot'";
# echo "\$relPath: '$relPath'";
# echo "\$file: '$file'";
# echo "\$l: '$l'";
# echo "\$m: '$m'";
# echo "\$r: '$r'";

isDiff=$(diff -q -Z $l $m | grep differ);

if [ -z "$isDiff" ]
then	if [ ! -z "$r" ]
		then	isDiff=$(diff -q -Z $m $r | grep differ);
		fi
fi

if [ ! -z "$isDiff" ]
then	echo 'Comparing: "'$file'"'
	WinMergeU -s -e -fl --ignoreeol $l $m $r &
else	echo '- - Skipping: "'$file'"'
fi