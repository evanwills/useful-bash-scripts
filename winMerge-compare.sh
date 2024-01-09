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
# * Relative directory path to file. If omitted, rel dir path should
#   be "XX"
# * File name. Name of file to be compared in all directories.
#
# Accepts optional 6th argument:
# * Number (in the list of files being processed) this file
#   represents
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

fileCount="$6";
copied=0;


# Check if both sides of a pair of files exist
# If one is missing and the other is not missing, copy the existing
# one to the missing file path
#
# @param $1 - first file path
# @param $2 - second file path
function copyMissingPair () {
	first="$1";
	second="$2";
	fName="$3";
	copyNum="$4";

	if [ -z "$first" ]
	then	# Can't copy if first path is empty
		return;
	fi;

	if [ -z "$second" ]
	then	# Can't copy if second path is empty
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
			echo $fileCount'	- - copying: "'$fName'"';

			cp "$first" "$second";

			copied=1;
			return;
		fi;
	else 	if [ ! -f "$first" ]
		then	if [ -f "$second" ]
			then	# Copied second file to first file path
				echo $fileCount'	- - copying: "'$fName'"';

				cp "$second" "$first";

				copied=1;
				return;
			fi
		fi
	fi;

	# Could not copy files
}

function addMissingDir () {
	newdir="$1";

	if [ ! -d "$newdir" ]
	then	echo;
		echo 'Creating missing directory:'
		echo '	"'$newdir'"';
		mkdir -p "$newdir"
	fi
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

addMissingDir "$lRoot$relPath";
addMissingDir "$mRoot$relPath";

if [ ! -z "$rRoot" ]
then	r=$rRoot$relPath$file;
	addMissingDir "$rRoot$relPath";
fi

if [ ! -d "$lRoot$relPath" ]
then	echo;
	echo 'Creating new directory: "'$lRoot$relPath'"';
	mkdir "$lRoot$relPath"
fi

copyMissingPair "$l" "$m" "$file" ;
copyMissingPair "$l" "$r" "$file";
copyMissingPair "$m" "$r" "$file";

suffix=$(echo "$file" | grep '\.\(png\|jpg\|ttf\|woff2\?\|eot\|\)$')

if [ -z "$suffix" ]
then	# Check if any of the files were copied. If so, don't
	# bother comparing.
	if [ $copied -eq 0 ]
	then
		isDiff=$(diff -q -Z $l $m | grep differ);

		if [ -z "$isDiff" ]
		then	if [ ! -z "$r" ]
				then	isDiff=$(diff -q -Z $m $r | grep differ);
				fi
		fi

		if [ ! -z "$isDiff" ]
		then	echo $fileCount'	Comparing: "'$file'"'
			WinMergeU -s -e -fl --ignoreeol $l $m $r &
		else	echo $fileCount'	- - Skipping: "'$file'"'
		fi
	fi
else	echo $fileCount'	- - Ignoring binrary file: "'$file'"';
fi
