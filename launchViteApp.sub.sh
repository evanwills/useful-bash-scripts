#!/bin/sh

echo 'launchViteApp.sub.sh';

repo="$1";
appName="$2";
startCode=$3;
delay=$4;
customCmd="$5";

if [ -z "$startCode" ]
then	startCode=0;
else	if [ "$startCode" == 'X' ]
	then	startCode=0;
	else	startCode=1;
	fi
fi
if [ -z "$delay" ]
then	delay=0;
else	if [ "$delay" == 'X' ]
	then	delay=0;
	else	delay=$(echo "$delay" | sed 's/[^0-9]+//g');

		if [ -z "$delay" ]
		then	delay=0;
		fi
	fi
fi

echo 'Inside launchViteApp.sub.sh';

lkFl=$(echo "$appName" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]\+/-/g');

lockFile=$HOME'/.'$lkFl'.vite.lock';

thisDir=$(realpath "$0" | sed "s/[^/']\+$//");
launchThis="/bin/sh $thisDir/launchViteApp.sh $repo;";
npmRun='/c/Program\ Files/nodejs/npm';

ffExe='"/c/Program Files/Firefox Developer Edition/firefox.exe"';
if [ ! -f "$ffExe" ]
then	ffExe='"/c/Program Files/Mozilla Firefox/firefox.exe"';
fi

# ---------------------------------------------------------
# debug() renders the name of the file, the line debug was called from (passed as the first parameter) the
#
# ---------------------------------------------------------
# debug () {
# 	echo '----------------------------------------';
# 	echo "launchViteApp.sub.sh - Line: $1";
# 	if [ ! -z "$2" ]
# 	then	if [ ! -z "$3" ]
# 			then	echo "      \$$2: '$3'";
# 			else	echo "$2";
# 			fi
# 			echo '----------------------------------------';
# 	fi;
# }

# debug 51 '1' "$1";
# debug 52 '2' "$2";
# debug 53 '3' "$3";
# debug 54 '4' "$4";
# debug 55 '5' "$5";
# debug 55 '5' "$6";
# debug 56 'repo' "$repo";
# debug 57 'appName' "$appName";
# debug 58 'startCode' "$startCode";

# debug 59 'delay' "$delay";
# debug 60 'customCmd' "$customCmd";
# debug 61 'lockFile' "$lockFile";
# debug 62 'thisDir' "$thisDir";
# debug 63 'launchThis' "$launchThis";


function waiteAwhile () {
	_timeout=$(echo "$1" | sed 's/^[^0-9]*\([0-9]\+\).*$/\1/i');
	_before=$2;
	_after=$3;
	_msg='';

	if [ -z "$_timeout" ]
	then	echo 'You must supply the number of seconds for the sleep timer';
		echo '"'"$1"'" could not be converted into a number';
		exit;
	fi

	_nowTime=$(date +%s);
	_endTime=$(($_nowTime + $_timeout));
	_left=$_timeout;
	echo
	echo;
	_sep='*'

	while [ $_left -gt 0 ]
	do	echo -ne "\e[2A\e[K\n$_sep You have $_left seconds left $_before  \n";
		sleep 0.3333;
		_nowTime=$(date +%s);
		_left=$(($_endTime - $_nowTime));
		if [ "$_sep" == ' ' ]
		then	_sep='*';
		else	_sep=' ';
		fi
	done
	echo -ne "\e[2A\e[K\nTime to $_after                                  \n";
}


# Go to the repo's directory
cd $repo

if [ $startCode -eq 1 ]
then	echo 'Attempting to start VS Code in "'$repo'"'
	code -n $repo &
fi

if [ ! -z "$ffProfile" ]
then	echo;
	echo Attempting to start Firefox profile: "'$ffProfile'";
	echo "\t$ffExe --no-remote -P $ffProfile &"
	"$ffExe" --no-remote -P $ffProfile &
fi

if [ -d $repo ]
then 	echo;

	if [ ! -f $lockFile ]
	then	touch $lockFile;
		echo 'About to start '$appName'.';
		echo;
		echo "(NOTE: I've set $lockFile to prevent duplicate servers being started for this application.)";
		echo;

		if [ $delay -gt 0 ]
		then	echo;
			echo '============================================================';
			echo "We're waiting $delay seconds while other things are done "
			echo "before starting $appName"
			waiteAwhile $delay "until we launch $appName" "launching $appName now";
			echo
			echo "We're done waiting.";
			echo '============================================================';

			echo; echo;
		fi

		if [ -z "$customCmd" ]
		then	# debug 150 "$npmRun run dev --host";
			/c/Program\ Files/nodejs/npm run dev --host
		else	tmp=$(echo "$customCmd" | grep /^npm run/ | sed 's/^npm run //');
			# debug 153 'tmp' "$tmp";

			if [ ! -z "$tmp" ]
			then	# debug 157 "$npmRun run $tmp";
				/c/Program\ Files/nodejs/npm run $tmp;
			else
				# debug 160 "$customCmd";
				$customCmd;
			fi
		fi

		rm $lockFile;

		echo; echo;
		echo "I've removed the lock file ($lockFile) so you can start up next time.";
		echo; echo;


		echo "to restart, just run";
		echo "	$launchThis";
		echo;
		echo;
	fi
fi

# kill -9 $PPID;