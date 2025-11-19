#!/bin/sh

thisDir=$(realpath "$0" | sed "s/[^/']\+$//");
targets=($thisDir'/../');
tmplName='';
vue2Modules='';
vue2=0;
# viteVersion='latest';

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

		'vue2')	;;
		'13')	_tmpl='vue2';
			vue2=1;
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

		'vue2')	_tmplName='Vue 2.x (Pure JS)'
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
			if [ $vue2 -eq 1 ]
			then 	_tmplName='Vue 2.x (Pure JS)';
			else 	_tmplName='Vanilla JS';
			fi
			# _tmplName='Vanilla JS';
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
	# echo '(Line: 145) $_tmplName: '$_tmplName;
	# echo '(Line: 145) $vue2: '$vue2;
}

forceEditorconfig () {
	_ec=$(pwd)'/.editorconfig';

	# Make sure there is a .editorconfig file in the application directory
	if [ ! -f "$_ec" ]
	then	cp $thisDir/new-vite/.editorconfig "$_ec"
	fi
}

forceGitAttributes () {
	_ga=$(pwd)'/.gitattributes';

	# Make sure there is a .gitattributes file in the application directory
	if [ ! -f "$_ga" ]
	then	cp $thisDir/new-vite/.gitattributes "$_ga"
	fi
}

forceEslintAirBnB () {
	_ec=$(pwd)'/.eslintrc.js';

	# Make sure there is a .eslintrc.js file in the application directory
	if [ ! -f "$_ec" ]
	then	cp $thisDir/new-vite/.eslintrc.js "$_ec"
	fi
}

# generateAppVue () {
# 	if [ ! -d "$1" ]
# 	then	echo 'Supplied path ("'$1'") is not a path to a local file system directory';
# 		exit;
# 	fi

# 	if [ ! -d "$1/src" ]
# 	then	echo 'Supplied path ("'$1'/src/") is not a path to a local file system directory';
# 		exit;
# 	fi

# 	_appVue="$1/src/App.vue";

# 	if [ ! -f "$_appVue" ]
# 	then	echo '<script setup>' > $_appVue;
# 		echo "import $element from './components/$element.vue'" >> $_appVue;
# 		echo '</script>' >> $_appVue;
# 		echo >> $_appVue;
# 		echo '<template>' >> $_appVue;
# 		echo '	<'$element'>Dummy content</'$element'>' >> $_appVue;
# 		echo '</template>' >> $_appVue;
# 		echo >> $_appVue;
# 		echo '<style lang="scss">' >> $_appVue;
# 		echo '</style>' >> $_appVue;
# 		echo >> $_appVue;
# 	fi
# }

# generateElementVue () {
# 	if [ ! -d "$1" ]
# 	then	echo 'Supplied path ("'$1'") is not a path to a local file system directory';
# 		exit;
# 	fi

# 	if [ ! -d "$1/src" ]
# 	then	echo 'Supplied path ("'$1'/src/") is not a path to a local file system directory';
# 		exit;
# 	fi

# 	if [ ! -d "$1/src/components" ]
# 	then	echo 'Supplied path ("'$1'/src/components/") is not a path to a local file system directory';
# 		exit;
# 	fi

# 	if [ -z "$2" ]
# 	then	echo 'Second parameter, ($elementName) must be a non-empty string';
# 		exit;
# 	fi

# 	_elemName="$2";
# 	_elemVue="$1/src/components/$_elemName.vue";

# 	if [ ! -f "$_elemVue" ]
# 	then	echo '<script>' > $_appVue;
# 		echo "import $_elemName from './components/$_elemName.vue'" >> $_elemVue;
# 		echo '</script>' >> $_elemVue;
# 		echo >> $_elemVue;
# 		echo '<template>' >> $_elemVue;
# 		echo '	<'$_elemName'>Dummy content</'$_elemName'>' >> $_elemVue;
# 		echo '</template>' >> $_elemVue;
# 		echo >> $_elemVue;
# 		echo '<style lang="scss">' >> $_elemVue;
# 		echo '</style>' >> $_elemVue;
# 		echo >> $_elemVue;
# 	fi
# }

# generateMainJs () {
# 	if [ ! -d "$1" ]
# 	then	echo 'Supplied path ("'$1'") is not a path to a local file system directory';
# 		exit;
# 	fi

# 	if [ ! -d "$1/src" ]
# 	then	echo 'Supplied path ("'$1'/src/") is not a path to a local file system directory';
# 		exit;
# 	fi

# 	_mainJs="$1/src/main.js";

# 	if [ ! -f "$_mainJs" ]
# 	then	echo "import { createApp } from 'vue'" > $_mainJs;
# 		echo "import './style.css'" >> $_mainJs;
# 		echo "import App from './App.vue'" >> $_mainJs;
# 		echo >> $_mainJs;
# 		echo "createApp(App).mount('#app')" >> $_mainJs;
# 		echo >> $_mainJs;
# 	fi
# }

# generateViteConfig () {
# 	if [ ! -d "$1" ]
# 	then	echo 'Supplied path ("'$1'") is not a path to a local file system directory';
# 		exit;
# 	fi

# 	_viteConfig="$1/vite.config.js";

# 	if [ ! -f "$_viteConfig" ]
# 	then	echo "import { defineConfig } from 'vite'" > $_viteConfig
# 		echo "import createVuePlugin from 'vite-plugin-vue2'" >> $_viteConfig
# 		# echo "import vue from '@vitejs/plugin-legacy'" >> $_viteConfig
# 		# echo "import vue from '@vitejs/plugin-vue'" >> $_viteConfig
# 		echo "" >> $_viteConfig
# 		echo "// https://vitejs.dev/config/" >> $_viteConfig
# 		echo "export default defineConfig({" >> $_viteConfig
# 		echo "  plugins: [vue()]," >> $_viteConfig
# 		echo "})" >> $_viteConfig
# 	else	sed -i 's/\(@vitejs\/plugin-\)vue/\1legacy/' $_viteConfig;
# 	fi
# }

echo;
echo;

project=$(echo "$1" | grep '^[a-z]\+\(-\+[a-z0-9]\+\)\+$');
element=$(sed -r 's/(^|-+)(\w)/\U\2/g' <<<"$project");

# echo '(line 321) $project: '$project;
# echo '(line 322) $element: '$element;

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
	# echo '  13 - "vue2" - Vue 2.x (pure JS)';
	echo
	read tmpl;

	tmpl=$(getRightTmpl "$tmpl");
	echo '(Line 360) $tmpl: '$tmpl;
	echo '(Line 361) $vue2: '$vue2;
done;

if [ $tmpl == 'vue' ]
then	vue2Modules='eslint ';
	vue2Modules=$vue2Modules'prettier ';
	vue2Modules=$vue2Modules'globals ';
	vue2Modules=$vue2Modules'@eslint/js ';
	vue2Modules=$vue2Modules'eslint-config-airbnb-base ';
	vue2Modules=$vue2Modules'eslint-config-prettier ';
	vue2Modules=$vue2Modules'eslint-plugin-import ';
	vue2Modules=$vue2Modules'eslint-plugin-vue ';
	vue2Modules=$vue2Modules'eslint-plugin-prettier  ';
	# vue2Modules=$vue2Modules'@vue/eslint-config-prettier';
fi

if [ $tmpl == 'vue2' ]
then	tmpl='vue';
	vue2Modules='vite-plugin-vue2 @vitejs/plugin-legacy vite-plugin-html vue-template-compiler sass sass-loader';
	# vue2Modules=$vue2Modules' postcss @fullhuman/postcss-purgecss autoprefixer';
	vue2=1;
	viteVersion='3';
fi

tmplName=$(getTmplName "$tmpl");


# echo '$tmplName:    "'$tmplName'"';
# echo '$vue2Modules: "'$vue2Modules'"';
# echo '$vue2:        "'$vue2'"';
# echo '$project:     "'$project'"';
# echo '$element:     "'$element'"';
# echo '$tmpl:        "'$tmpl'"';

# exit;
targetDir='';

_len=${#targets[@]};

if [ $_len -gt 1 ]
then	if [ ! -z "$3" ]
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
			then	targetDir=${targets[0]};
			else	targetDir=$(getRightTarget "$targetDir");
			fi
			echo;
		done
	fi
else
	targetDir=${targets[0]};
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

	echo;
	echo 'Current working directory:'
	echo '	'$(pwd);
	echo;
	echo 'moving to diretory:';
	echo '    '$targetDir;

	cd "$targetDir";

	echo;
	echo 'Current working directory:'
	echo '	'$(pwd);
	echo;

	echo;
	echo "npm create vite@latest $project -- --template $tmpl;";
	echo;

	npm create vite@latest $project -- --template $tmpl;

	echo;
	echo 'Current working directory:'
	echo '	'$(pwd);
	echo;
	echo 'Moving to project diretory:';
	echo '	'$targetDir$project;

	cd $targetDir$project;

	echo;
	echo 'Current working directory:'
	echo '	'$(pwd);
	echo;

	code -n $(pwd) &
	npm install;
	if [ ! -z $vue2Modules ]
	then	npm install $vue2Modules;
	fi;

	forceEditorconfig;
	forceGitAttributes;

	if [ $tmpl === 'vue' ]
	then	forceEslintAirBnB;
	fi

	if [ -f README.md ]
	then	mv README.md README.vite.md
	fi;

	echo '# `<'$element'>`' > README.md
	echo >> README.md
	echo >> README.md
	echo 'See info about [Vite and '$tmplName'](README.vite.md)' >> README.md
	echo >> README.md

	if [ -f src/components/HelloWorld.vue ]
	then	mv src/components/HelloWorld.vue src/components/$element.vue
		sed -i 's/HelloWorld/'$element'/g' **/*.vue **/**/*.vue
	fi;

	toGit='';

	gitFileList=(.editorconfig .gitignore index.html package.json package-lock.json README.* public/vite.svg src/assets/vue.svg src/App.vue src/style.cs src/components/$element.vue tsconfig.json tsconfig.node.json vite.config.ts src/main.ts src/vite-env.d.ts vite.config.js src/main.js)

	for file in "${gitFileList[@]}"
	do	if [ -f "$file" ]
		then	toGit=' '$file;
		fi;
	done

	git init;
	git add $toGit

	git commit -m 'initial commit';

	npm run dev

	kill -9 $PPID;
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
