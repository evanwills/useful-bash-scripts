#!/bin/sh

lockFile=$HOME'/VMware.lock';

echo;

if [ -f "$1" ]
then	path=$(echo "$1" | sed 's/\([() ]\)/\\\1/ig');
	if [ ! -f $lockFile ]
	then	touch $lockFile

		echo 'About to launch VMware';
		echo;
		echo "(NOTE: I've set $lockFile to prevent duplicate instances of VMware being started.)";

		$path

		echo;

		rm $lockFile

		echo; echo;
		echo "I've removed the lock file ($lockFile) so you can start up next time.";
		echo; echo;

	else	echo 'Looks like VMware is already running';
	fi
else	echo 'Could not find path to VMware';
fi

