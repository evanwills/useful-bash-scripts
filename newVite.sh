#!/bin/sh

targets=('~/code/');
tmplName='';

getRightTarget () {
	_path=${targets[$1]};
	if [ ! -z "$_path" ]
	then	if [ -d "$_path" ]
		then	echo "$_path";
		else	echo '';
		fi
	else	echo '';
	fi
}

getRightTmpl () {
	_tmpl=$(echo $1 | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z-]+//ig');

	case "$_tmpl" in
		'vue')	;;
		'1')	_tmpl='vue';
			tmplName='VueJS'
			;;

		'vue-ts')	;;
		'2')	_tmpl='vue-ts';
			;;

		'lit')	;;
		'3')	_tmpl='lit';
			;;

		'lit-ts')	;;
		'4')	_tmpl='lit-ts';
			;;

		'vanilla')	;;
		'5')	_tmpl='vanilla';
			;;

		'vanilla-ts')	;;
		'6')	_tmpl='vanilla-ts';
			;;

		'react')	;;
		'7')	_tmpl='react';
			;;

		'react-ts')	;;
		'8')	_tmpl='react-ts';
			;;

		'preact')	;;
		'9')	_tmpl='preact';
			;;

		'preact-ts')	;;
		'10')	_tmpl='preact-ts';
			;;

		'svelte')	;;
		'11')	_tmpl='svelte';
			;;

		'svelte-ts')	;;
		'12')	_tmpl='svelte-ts';
			;;

		*)	_tmpl='';
			;;
	esac

	echo $_tmpl;
}

getTmplName () {
	case "$1" in
		'vue')	_tmplName='VueJS'
			;;

		'vue-ts')
			_tmplName='VueJS + Typescript';
			;;

		'lit')	_tmplName='Lit Element';
			;;

		'lit-ts')
			_tmpl='Lit Element + Typescript';
			;;

		'react')
			_tmplName='React';
			;;

		'react-ts')
			_tmplName='React + Typescript';
			;;

		'preact')
			_tmplName='Preact';
			;;

		'preact-ts')
			_tmplName='Preact + Typescript';
			;;

		'vanilla')
			_tmplName='Vanilla JS';
			;;

		'vanilla-ts')
			_tmplName='Vanilla + Typescript';
			;;

		'svelte')
			_tmplName='Svelt';
			;;

		'svelte-ts')
			_tmplName='Svelt + Typescript';
			;;

		*)	_tmplName='';
			;;
	esac

	echo $_tmplName;
}

forceEditorconfig () {
	_ec=$(pwd)'/.editorconfig';

	# Make sure there is a .editorconfig file in the application directory
	if [ ! -f "$_ec" ]
	then	echo '# .editorconfig helps developers define and maintain consistent coding' > $_ec;
		echo '# styles between different editors and IDEs' >> $_ec;
		echo '' >> $_ec;
		echo '# for more information about the properties used in this file, please see' >> $_ec;
		echo '# the .editorconfig documentation: http://editorconfig.org/' >> $_ec;
		echo '' >> $_ec;
		echo '# this is the top-most .editorconfig file; do not search parent directories' >> $_ec;
		echo 'root = true' >> $_ec;
		echo '' >> $_ec;
		echo '# applied to all files' >> $_ec;
		echo '[*]' >> $_ec;
		echo 'indent_style = space' >> $_ec;
		echo 'indent_size = 2' >> $_ec;
		echo 'end_of_line = lf' >> $_ec;
		echo 'charset = utf-8' >> $_ec;
		echo 'trim_trailing_whitespace = true' >> $_ec;
		echo 'insert_final_newline = true' >> $_ec;
		echo '' >> $_ec; echo '' >> $_ec;
		echo '[*.php]' >> $_ec;
		echo 'indent_size = 4' >> $_ec;
		echo '' >> $_ec; echo '' >> $_ec;
		echo '[*.{html,svg,xhtml,htm}]' >> $_ec;
		echo 'indent_style = tab' >> $_ec;
		echo 'insert_final_newline = false' >> $_ec;
		echo 'indent_size = 4' >> $_ec;
		echo '' >> $_ec; echo '' >> $_ec;
		echo '[*.sh]' >> $_ec;
		echo 'insert_final_newline = false' >> $_ec;
		echo 'indent_style = tab' >> $_ec;
		echo 'indent_size = 8' >> $_ec;
		echo '' >> $_ec; echo '' >> $_ec;
		echo '[{.bashrc}]' >> $_ec;
		echo 'insert_final_newline = false' >> $_ec;
		echo 'indent_style = tab' >> $_ec;
		echo 'indent_size = 8' >> $_ec;
		echo '' >> $_ec; echo '' >> $_ec;
		echo '[*.md]' >> $_ec;
		echo 'trim_trailing_whitespace = false' >> $_ec;
		echo '' >> $_ec; echo '' >> $_ec; echo '' >> $_ec;
		echo '# the indent size used in the `package.json` file cannot be changed' >> $_ec;
		echo '# https://github.com/npm/npm/pull/3180#issuecomment-16336516' >> $_ec;
		echo '[{.travis.yml,package.json}]' >> $_ec;
		echo 'indent_size = 2' >> $_ec;
		echo 'indent_style = space' >> $_ec;
		echo '' >> $_ec;
	fi
}

echo;
echo;

project=$(echo "$1" | grep '^[a-z]\+\(-[a-z0-9]\+\)\+$');
element=$(sed -r 's/(^|-)(\w)/\U\2/g' <<<"$project");

while [ -z "$project" ]
do	echo;
	echo 'Please enter the name of your new project (without spaces):'
	echo '(It should be in kebab case format)';
	echo
	read project;
	if [ ! -z "$project" ]
	then	project=$(echo $project | sed 's/[^a-z0-9_-]\+/-/ig');
		echo '$project: '$project;
	fi
done;


if [ ! -z "$2" ]
then	tmpl=$(getRightTmpl "$2");
fi

while [ -z "$tmpl" ]
do	echo;
	echo 'Please enter framework/language pair for your new project:'
	echo '(either enter the number beside the framework or the quoted framework name)';
	echo;
	echo '   1 - "vue" - Vue (pure JS)';
	echo '   2 - "vue-ts" - Vue (TypeScript)';
	echo '   3 - "lit" - Lit Element (pure JS)';
	echo '   4 - "lit-ts" - Lit Element (Typescript)';
	echo '   5 - "vanilla" - Pure Javascript (no framework)';
	echo '   6 - "vanilla-ts" - Pure TypeScript (no framework)';
	echo '   7 - "react" - React (pure JS)';
	echo '   8 - "react-ts" - React (TypeScript)';
	echo '   9 - "preact" - React (pure JS)';
	echo '  10 - "preact-ts" - React (TypeScript)';
	echo '  11 - "svelte" - Svelt (pure JS)';
	echo '  12 - "svelte-ts" - Svelte (TypeScript)';
	echo
	read tmpl;

	tmpl=$(getRightTmpl "$tmpl");
	# echo '$tmpl: '$tmpl;
done;

tmplName=$(getTmplName "$tmpl");
targetDir='';

if [ ! -z "$3" ]
then	targetDir=$(getRightTarget "$3");
fi

if [ -z "$targetDir" ]
then	echo 'The current target diretory (when the project will be created) is:'
	echo '   "'${targets[0]}'"';
	echo;

	while [ "$targetDir" == '' ]
	do	echo;
		echo 'Please enter the number for the target directory you want:';

		for _i in ${!targets[@]};
		do	echo '  '$_i'. "'${targets[$_i]}'"';
		done
		echo 'or, press enter to use current target.'
		echo;
		read targetDir;

		targetDir=$(echo "$targetDir" | tr '[:upper:]' '[:lower:]' | sed 's/^[ \t]+\|[ \t]+$//g');

		if [ -z "$targetDir" ]
		then	targetDir=$litCompDir;
		else	targetDir=$(getRightTarget "$targetDir");
		fi
		echo;
	done
fi

if [ ! -z "$project" ]
then	echo 'About to create a new <'$project'></'$project'> project';
	echo 'using '$tmplName;
	echo 'in "'$targetDir'"';
	echo;
	echo 'First Vite will do all the scaffolding for your component.';
	echo "Next we'll install all the node modules.";
	echo "Then we'll launch a development server for your new component.";
	echo "And finally, we'll launch VS Code so you can start work.";

	cd "$targetDir";

	npm init vite@latest $project -- --template $tmpl;

	cd $project;

	code -n $(pwd) &
	npm install;

	forceEditorconfig

	mv README.md README.vite.md
	echo '# `<'$element'>`' > README.md
	echo >> README.md
	echo >> README.md
	echo 'See info about [Vite and '$tmplName'](README.vite.md)' >> README.md
	echo >> README.md

	mv src/components/HelloWorld.vue src/components/$element.vue
	sed -i 's/HelloWorld/'$element'/g' **/*.vue **/**/*.vue

	git init;
	git add .editorconfig .gitignore index.html package.json package-lock.json README.* tsconfig.json tsconfig.node.json vite.config.ts public/vite.svg .vscode/extensions.json src/assets/vue.svg src/App.vue src/main.ts src/style.css src/vite-env.d.ts src/components/$element.vue
	git commit -m 'initial commit';

	npm run dev

	exit;
	# echo;
	# echo;

	# echo "cd $targetDir;";
	# echo;
	# echo "npm init vite@latest $project -- --template $tmpl;";
	# echo;
	# echo "cd $project;";
	# echo;
	# echo "code -n $(pwd) &";
	# echo;
	# echo "npm install;";
	# echo;
	# echo "npm run dev";
else
	echo 'The name you specified ("'$1'") is not valid';
fi
echo;
