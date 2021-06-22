#!/bin/sh

# -----------------------------------------------
# This is a template script

echo; echo; echo; echo; echo;

tmp='';

getRightFile () {
        local dbName="$1"'__';
	local output='';

        if [ ! -z "$1" ]
        then	for f in ./$dbName*;
		do	if [ ! -z $(echo $f | grep '\.tar\.bz2$') ]
			then
                                # echo '$output = '$output;
                                output=$(echo $f | sed 's/^\([^\/]\+\/\)\+//');
                                # echo '$output = '$output;
			fi
		done
	fi

	echo '$output = '$output;
	tmp=$output;
}


restoreDB () {
        local file="$1";
        local dbName="$2";
        local decompressedDB='';
        local rightFile='';
        local oldDbName='';

        if [ ! -z "$file" ]
        then    if [ -f $file ]
                then    decompressedDB=$(echo $file | sed 's/\.tar\.bz2$//i')
                        echo '$decompressedDB = '$decompressedDB;

                        if [ "$decompressedDB" != "$file" ]
                        then    tar -xjvf $file;
                                rightFile=$(ls | grep $decompressedDB);
                                echo '$rightFile = '$rightFile;

                                if [ ! -z "$rightFile" ]
                                then    if [ ! -z "$dbName" ]
                                        then
						# Rewrite the DB
						oldDbName=$(grep '\-\- Current Database: `[^`]\+`' $decompressedDB | sed 's/-- Current Database: `\([^`]\+\)`/\1/i');
						# oldDbName=$(echo $oldDbName);
                                                grep '\-\- Current Database: `\([^`]\+\)`' $decompressedDB;
                                                echo '$oldDbName = '$oldDbName;
                                                echo '$dbName = '$dbName;

                                                if [ ! -z "$oldDbName" ]
                                                then    # Make sure the specified DB name in the dumped SQL matches the target DB
							sed -i 's/'$oldDbName'/'$dbName'/g' $decompressedDB;

							# This script assumes we already have an existing database
							# so no need to create a new one (especially since there are
							# compatibility issues with character sets)
							sed -i 's/^\(CREATE DATABASE[^;]\+;\)/-- \1/i' $decompressedDB;
                                                fi
                                        fi

                                        echo 'About to run command ';
                                        echo "  /bin/sh /home/evan/restoreDB.sh $dbName $decompressedDB;";
                                        /bin/sh /home/evan/restoreDB.sh $dbName $decompressedDB;
                                        echo; echo; echo; echo; echo;
                                fi
                        fi
                fi
        fi

}

getRightFile 'dumped DB1 name';
restoreDB $tmp '[desitination db1 name]';


getRightFile 'dumped DB2 name';
restoreDB $tmp '[desitination db2 name]';


getRightFile 'dumped DB3 name';
restoreDB $tmp '[desitination db3 name]';


# head -n 20 acu_form_build__2021-06-22--15-13-24.sql

echo; echo; echo; echo; echo;
