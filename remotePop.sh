#!/bin/sh

pwd=$(pwd)'/'
repo=$(basename `git rev-parse --show-toplevel`)
evan=0
cOpen='\/\/\ ';
cClose='';
shOpen='# ';
shClose='';
xmlOpen='<!--\ ';
xmlclose='\ -->';
# cssOpen='/* ';
# cssclose=' */';
commentOpen='';
commentClose='';

if [ $repo == '' ]
then	echo 'Not inside a repo';
	exit;
fi

echo '$pwd: '$pwd
if [[ $pwd == *"c/Users/evwills/Documents/Evan/code"* ]]
then	evan=1;
	stashPath='/c/Users/evwills/Documents/Evan/code/remote-stash/'$repo'/';
else	stashPath='/c/Users/evwills/Documents/ACU/remote-stash/'$repo'/';
fi

if [ ! -d $stashPath ]
then	echo; echo; echo 'This repo ('$repo') has no remote directory for stashed files'; echo; echo;
	exit;
fi
empty=$([ "$(ls -A $stashPath)" ] && echo 0 || echo 1)
echo '$empty: '$empty;

if [ $empty -eq 1 ]
then	echo; echo; echo 'There are no stashed files for this repo ('$repo')'; echo; echo;
fi

purge=0
if [ ! -z "$1" ]
then	if [ "$1" == 'purge']
	then	purge=1
	fi
fi

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
				commentOpen='\/\* ';
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


echo '$evan: '$evan
echo '$repo: '$repo

popRemotely () {
	echo 'inside popRemotely()'
	echo '$1: '$1
	echo '$stashPath: '$stashPath

	if [ ! -z "$1" ]
	then	file=$1

		if [ -f "$file" ]
		then	echo;
			echo;
			echo '=========================================';
			echo;
			echo 'About to remotely pop';
			echo;
			echo 'Source file:                  '$file;
			echo 'Absolute path to destination: '$stashPath$repo'/';
			echo;

			setCommentWrapper $file;
			echo '$file: '$file
			echo '$commentOpen: '$commentOpen;
			echo '$commentClose: '$commentClose;

			grepR='"'$commentOpen'origin path:\ .*?'$commentClose'"';
			sedR="'s/^$commentOpen""origin path:\ //'";
			echo '$grepR: '$grepR;
			echo '$sedR: '$sedR;

			dest=$(grep -P $grepR $file | sed $sedR)
			echo '$dest: '$dest

			if [ -z $commentClose ]
			then	dest=$(echo $dest | sed 's/'$commentClose'$//')
				echo '$dest: '$dest
			fi


			# dest=$stashPath$repo'/';

			# cp $file $stashPath$repo;


			# if [ $commentOpen != '' ]
			# then	# add the absolute path to the original
			# 	# file to the bottom of the stashed file

			# 	echo '' >> $dest;
			# 	echo '' >> $dest;
			# 	echo '' >> $dest;
			# 	echo $commentOpen'origin path: '$file$commentClose >> $dest;
			# 	echo '' >> $dest;
			# fi

			# echo;
			# ls -alh $stashPath$repo |grep .$fileType
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

echo '$stashPath: '$stashPath

popable=$(ls -U $stashPath);
a=0;
while [ ! -z "$popable" ]
do	item=$(echo $popable | sed 's/^\([^\t ]\+\)\+[\t ]*.*$/\1/');
	popable=$(echo $popable | sed 's/^[^\t ]\+[\t ]*\(.*\)$/\1/');

	if [ ! -z $item ]
	then	if [ -f $stashPath$item ]
		then	popRemotely $stashPath$item
		else	echo 'File '$stashPath$item' does not exist!';
		fi
	fi
done
echo $popable;