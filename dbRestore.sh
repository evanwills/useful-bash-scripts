#!/bin/sh

root=$(pwd);
newRoot=$root;
user='root';
password='password';
badSrc=0;
deleteSrc=0;
revertSrc=0;
source='';
mariaPrefix='winpty';
mariaBase='/c/Program Files/MariaDB 10.6/bin/mariadb.exe';

decompressedExists () {
	tmpSrc="$root/$1"

	echo '15 - $tmpSrc: '$tmpSrc;
	echo '16 - $source: '$source;
	echo '17 - $deleteSrc: '$deleteSrc;
	echo '18 - $badSrc: '$badSrc;

	if [ -f "$tmpSrc" ]
	then	source=$tmpSrc;
		deleteSrc=1;
	else	badSrc=1;
	fi
	echo '25 - $source: '$source;
	echo '26 - $deleteSrc: '$deleteSrc;
	echo '27 - $badSrc: '$badSrc;
}

decompressSQL () {
	src="$1"
	ext=$(echo $src | sed 's/^\([^.]\+\.\)\+\(tar\.\)\?\(gz\|bz2\)\?$/\3/i')
	isTar=$(echo $src | sed 's/^\([^.]\+\.\)\+\(\(tar\)\.\)\(gz\|bz2\)\?$/\3/i')
	mode='-xzvf'
	echo '35 - $src: '$src;
	echo '36 - $ext: '$ext;
	echo '37 - $isTar: '$isTar;

	if [ "$isTar" == 'tar' ]
	then	if [ "$ext" == 'bz2' ]
		then	mode='-xjvf';
		fi

		echo
		echo '--------------------------------------';
		echo
		echo '47 - Decompressing '$ext' file:'
		echo '	'$src
		echo '49 - tar '$mode' '$src;
		tar $mode $src
		ls -alh
		newSrc=$(echo $src | sed 's/^\([^.]\+\(\.[^.]\+\)*\)\.tar\.'$ext'$/\1/');
		ls -alh |grep $newSrc

		echo '55 - $src: '$src;
		echo '56 - $newSrc: '$newSrc;
		echo
		echo '--------------------------------------';
		echo

		echo '61 - $source: '$source;
		echo '62 - $newSrc: '$newSrc;
		decompressedExists $newSrc;
		echo '64 - $source: '$source;
		echo '--------------------------------------';
		echo
	else	if [ "$ext" == 'gz' ]
		then	echo 'Unzipping '$ext' file:'
			echo '	'$src

			gunzip -k $src
			newSrc=$(echo $src | sed 's/^\([^.]\+\(\.[^.]\+\)*\)\.gz$/\1/')

			echo '72 - $src: '$src;
			echo '73 - $newSrc: '$newSrc;

			decompressedExists $newSrc;
		fi
	fi
}

if [ ! -z "$1" ]
then
	if [ -f "$2" ]
	then
		source="$root/$2";
		newRoot=$(echo $source | sed 's/[^\/]\+$//');
		fileOnly=$(echo $source | sed 's/\([^\/]\+\/\)\+\([^\/]\+\)$/\2/' | sed 's/\///');
		oldSource="$source";
		dbName="$1";
		oldDbName="$dbName"

		echo 'Sbout to try decompressing '$source;
		cd $newRoot;
		decompressSQL $fileOnly;
		echo '$source: '$source;

		# Check if we have a decompressed SQL file.
		if [ $badSrc -eq 1 ]
		then	echo;
			echo 'Could not find file:';
			echo "	$source";
			echo 'decompressed from file:';
			echo "	$oldSource";
			echo;
			echo "Could be that my pattern matching didn't go as expected."
			echo "This means I have no SQL file to work with.";
			echo;
			echo 'Also, you will probably have to manually delete the file that was just decompressed.'
			echo;
			exit;
		fi

		oldDbName=$(grep '^USE' $source | sed 's/^[^`]\+`\([^`]\+\)`.*$/\1/')

		echo;
		echo;
		echo 'Old DB Name: '$oldDbName;
		echo;

		if [ "$dbName" != "$oldDbName" ]
		then	echo "We have to update the SQL file to use the new DB name";
			if [ -w "$source" ]
			then	revertSrc=1
				echo;
				echo '======================================';
				echo;
				echo 'Now updating the SQL '$source' to use "'$dbName'" (instead of "'$oldDbName'")';
				sed -i 's/'$oldDbName'/'$dbName'/g' $source
				echo;
				echo 'Updated version:';
				echo $(grep '^USE' $source | sed 's/^[^`]\+`\([^`]\+\)`.*$/\1/')
			else	echo;
				echo $source' is not writable';
				echo;
				exit;
			fi
		fi

		echo;
		echo 'About to restore DB: '$dbName;
		echo 'From: '$source;
		echo
		echo '======================================';
		echo
		# echo 'mariadb -v -p -u '$user $dbName' < '$source;
		# echo $mariaBase' '$user' -p '$dbName' < '$source;
		if [ -z "$password" ]
		then	# mariadb -v -u $user -p $dbName < $source
			echo $mariaPrefix' '$mariaBase' -v -u '$user' -p '$dbName' < '$source;
			$mariaPrefix $mariaBase -v -u $user -p $dbName < $source
		else	# mariadb -v -password=$password -u $user $dbName < $source
			echo $mariaPrefix' '$mariaBase' -v -u '$user' -p'$password' '$dbName' < '$source;
			$mariaPrefix "$mariaBase" -v -u $user -p$password $dbName < $source
		fi
		echo
		echo '======================================';
		echo

		if [ $deleteSrc -eq 1 ]
		then	echo 'I decompressed '$oldSource' so I will removed that decompressed file ('$source')';
			rm $source;
		else	if [ $revertSrc -eq 1 ]
			then	echo;
				echo '======================================';
				echo;
				echo 'I previously updated the SQL file to use the specified DB: "'$dbName'" (instead of "'$oldDbName'")'
				echo 'I will now revert that change';
				echo;
				echo 'Current version:';
				echo $(grep '^USE' $source | sed 's/^[^`]\+`\([^`]\+\)`.*$/\1/');

				sed -i 's/'$dbName'/'$oldDbName'/g' $source

				echo;
				echo 'Restored version:';
				echo $(grep '^USE' $source | sed 's/^[^`]\+`\([^`]\+\)`.*$/\1/');
			fi
		fi
		cd $root
		exit;
	fi
fi


echo 'You must specify a database name as the ';
echo 'first argument passed to this script.';
echo 'AND a dump file as the second argument.';

