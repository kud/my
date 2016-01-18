#! /usr/bin/env zsh

branches=$(git branch --merged|grep -v 'master')

echo "List of branches merged:"
echo $branches

read \?"Press any key to continue the deletion… or ctrl+c to stop."

git branch -D $branches
