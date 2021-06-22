#!/bin/sh

pwd=$(pwd)'/'
repo=$(basename `git rev-parse --show-toplevel`)
evan=0
cOpen='// ';
cClose='';
shOpen='# ';
shClose='';
xmlOpen='<!-- ';
xmlclose=' -->';
cssOpen='/* ';
cssclose=' */';
commentOpen='';
commentClose='';

if [ $repo == '' ]
then	echo 'Not inside a repo';
	exit;
fi

echo '$pwd: '$pwd
if [[ $pwd == *"c/Users/evwills/Documents/Evan/code"* ]]
then	evan=1;
	stashPath='/c/Users/evwills/Documents/Evan/code/remote-stash/';
else	stashPath='/c/Users/evwills/Documents/ACU/remote-stash/';
fi

echo '$evan: '$evan
echo '$repo: '$repo

setCommentWrapper () {
	commentOpen='';
	commentClose='';

	if [ ! -z "$1" ]
	then	fileType=$(echo $1 | sed 's/^\([^\.]*\.\)\+//');

		case $fileType in
			# ==================================
			'sh')
				commentOpen='# ';
				commentClose='';
				;;

			# ==================================

			'css')
				commentOpen='/* ';
				commentClose=' */';
				;;

			# ==================================

			'js')
				commentOpen=$cOpen;
				commentClose=$cClose;
				;;
			'json')
				commentOpen=$cOpen;
				commentClose=$cClose;
				;;
			'scss')
				commentOpen=$cOpen;
				commentClose=$cClose;
				;;
			'php')
				commentOpen=$cOpen;
				commentClose=$cClose;
				;;
			'cs')
				commentOpen=$cOpen;
				commentClose=$cClose;
				;;

			# ==================================

			'html')
				commentOpen=$xmlOpen;
				commentClose=$xmlclose;
				;;
			'htm')
				commentOpen=$xmlOpen;
				commentClose=$xmlclose;
				;;
			'cshtml')
				commentOpen=$xmlOpen;
				commentClose=$xmlclose;
				;;
			'svg')
				commentOpen=$xmlOpen;
				commentClose=$xmlclose;
				;;
			'xml')
				commentOpen=$xmlOpen;
				commentClose=$xmlclose;
				;;

			# ==================================
		esac
	fi
}

stashRemotely () {
	if [ ! -z "$1" ]
	then	file="$pwd$1"
		echo;
		echo;
		echo '=========================================';
		echo;
		echo 'About to remotely stash';
		echo;
		echo 'Source file:                  '$file;
		echo 'Absolute path to destination: '$stashPath$repo'/';
		echo;

		if [ -f "$file" ]
		then	if [ ! -d "$stashPath$repo" ]
			then	echo 'creating new directory: '$stashPath$repo
				mkdir $stashPath$repo
			fi

			dest=$stashPath$repo'/';

			cp $file $stashPath$repo;

			fileName=$(echo $file | sed 's/^\([^\/]*\/\)\+//');
			dest=$dest$fileName;

			setCommentWrapper $fileName

			if [ $commentOpen != '' ]
			then	# add the absolute path to the original
				# file to the bottom of the stashed file

				echo '' >> $dest;
				echo '' >> $dest;
				echo '' >> $dest;
				echo $commentOpen'origin path: '$file$commentClose >> $dest;
				echo '' >> $dest;
			fi

			echo;
			ls -alh $stashPath$repo |grep .$fileType
		fi
	fi
}

nothingLeft () {
	echo;
	echo;
	echo 'No more parameters passed';
	echo;
	exit;
}


if [ ! -z "$1" ]
then	stashRemotely "$1";
else	nothingLeft;
fi

if [ ! -z "$2" ]
then	stashRemotely "$2";
else	nothingLeft;
fi

if [ ! -z "$3" ]
then	stashRemotely "$3";
else	nothingLeft;
fi

if [ ! -z "$4" ]
then	stashRemotely "$4";
else	nothingLeft;
fi

if [ ! -z "$5" ]
then	stashRemotely "$5";
else	nothingLeft;
fi

if [ ! -z "$6" ]
then	stashRemotely "$6";
else	nothingLeft;
fi

if [ ! -z "$7" ]
then	stashRemotely "$7";
else	nothingLeft;
fi

if [ ! -z "$8" ]
then	stashRemotely "$8";
else	nothingLeft;
fi

if [ ! -z "$9" ]
then	stashRemotely "$9";
else	nothingLeft;
fi