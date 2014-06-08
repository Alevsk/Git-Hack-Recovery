#!/bin/bash
#
# Fetch the last changes of a repository and update the local files
#
# @autor Alevsk 2014
# Usage: ./script.sh remote-name branch-name
# Arguments:
#   remote-name: usually called origin
#   branch-name: usually called master

if [[ $# -ne 2 ]] ; then
  echo 'Usage: ./script.sh remote-name branch-name'
  exit 1
fi

args=("$@")

git fetch ${args[0]}

if git status | grep -q "Your branch is behind"; then
  echo "There are some new updates in origin/master"
  git merge ${args[0]} ${args[1]}
	
else
  echo "everything is up to date"
fi