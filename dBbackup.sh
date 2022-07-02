#!/bin/sh

user='root';
password='password';

if [ ! -z "$1" ]
then	dbName="$1";
	startTime=$(date +'%Y-%m-%d--%H-%M-%S' | sed 's/ /0/g');
	backupFile=$dbName'__'$startTime'.sql';

	echo;
	echo 'About to backup DB: '$dbName;
	echo 'to: '$backupFile;
	echo;

	mysqldump -v --password=$password -u $user $dbName > $backupFile;

	echo 'Creating BZ2 compressed version.'

	tar -cjvf $backupFile'.tar.bz2' $backupFile;
	rm $backupFile;
else
	echo 'You must specify a database name as the ';
	echo 'first argument passed to this script.';
fi

