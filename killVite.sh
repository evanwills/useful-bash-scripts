#!/bin/sh

locks=($(ls -a $HOME | grep '\.vite\.lock'))

c=0;
# echo ${locks[@]}
for i in ${locks[@]}
do	lock=$HOME/$i

	name=$(echo $i | sed 's/^\.\([^.]\+\)\.vite\.lock$/\1/i');

	echo 'Femoving lock for '$name' ('$lock')';

	rm $lock;
	c=$((c+1));
done

fLock=$HOME'/.ff-lock';
if [ -f $fLock ]
then	echo 'Removing lock for FireFox profiles: '$fLock;
	rm $fLock;
	c=$((c+1));
fi

if [ $c -eq 0 ]
then	echo 'No locks to delete this time';
fi;

# kill -9 $PPID;
