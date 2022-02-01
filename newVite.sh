#!/bin/sh

element="$1";

echo;
echo;
echo 'About to create a new "'$element'" web component';
echo 'using Lit-Element & TypeScript';
echo;

npm init vite@latest $element -- --template lit-ts

cd $element;

npm install;
npm run dev;
vscode;