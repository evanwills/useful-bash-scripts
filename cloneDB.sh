#!/bin/sh


user='root';
password='password';
badSrc=0;
deleteSrc=0;
revertSrc=0;
source='';
sourceDB='';
destDB='';
dbSuffix='TEST'

if [ ! -z "$1" ]
then	sourceDB="$1";
fi

if [ ! -z "$2" ]
then	dbSuffix="$2";
fi

if [ $dbSuffix != 'TEST' ]
then	if [ $dbSuffix != 'DEV' ]
	then	if [ $dbSuffix != 'PROD' ]
		then	dbSuffix='TEST';
		fi
	fi
fi

if [ ! -z "$3" ]
then	destDB="$3";
else	destDB=$(echo $sourceDB | sed 's/__[A-Z]+$/__'$dbSuffix'/');
fi

if [ ! -z "$sourceDB" ]
then
	startTime=$(date +'%Y-%m-%d--%k-%M-%S');
	backupFile=$sourceDB'__'$startTime'.sql';

	echo;
	echo 'About to backup DB: '$sourceDB;
	echo 'to: '$backupFile;
	echo;

	if [ -z "$password" ]
	then	mysql -v -p -u $user $sourceDB > $backupFile;
	else	mysqldump -v --password=$password -u $user $sourceDB > $backupFile;
	fi

	tar -cjvf $backupFile'.tar.bz2' $backupFile;

	sed -i 's/'$sourceDB'/'$destDB'/g' $backupFile;

	echo;
	echo 'About to restore DB: '$destDB;
	echo 'From: '$backupFile;
	echo

	if [ -z "$password" ]
	then	mysql -v -p -u $user $dbName < $backupFile;
	else	mysql -v -password=$password -u $user $dbName < $backupFile;
	fi

	rm $backupFile;
fi