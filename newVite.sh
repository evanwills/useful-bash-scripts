#!/bin/sh

webCompDir='/c/Users/evwills/Documents/Evan/code/web-components';


echo;
echo;

if [ ! -z "$1" ]
then	element=$(echo "$1" | grep '^[a-z]\+\(-[a-z]\+\)\+$');

	if [ ! -z "$element" ]
	then	echo 'About to create a new <'$element'></'$element'> web component';
		echo 'using Lit-Element & TypeScript';
		echo;
		echo 'First Vite will do all the scaffolding for your component.';
		echo "Next we'll install all the node modules.";
		echo "Then we'll launch a development server for your new component.";
		echo "And finally, we'll launch VS Code so you can start work.";

		cd $webCompDir;

		npm init vite@latest $element -- --template lit-ts;

		cd $element;

		npm install;
		npm run dev &
		code -n $(pwd) &
	else
		echo 'The name you specified ("'$1'") is not valid';
	fi
else
	echo 'You must specify a name for your element';
fi
echo;
