#!/bin/sh

git diff $1;

echo;
echo;
echo '------------------------------'; 
echo $1;
echo '------------------------------'; 
echo;
echo;

git status;
