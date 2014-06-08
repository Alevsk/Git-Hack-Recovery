#!/bin/bash
#
# Check for changes in local files and revert to last 
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

if git status | grep -q "modified"; then
  echo "modified file"
  git fetch ${args[0]}
  git reset --hard ${args[0]}/${args[1]}

elif git status | grep -q "Untracked"; then
  echo "untracked files ... start deleting process"
  git fetch ${args[0]}
  git clean -f -d	

else
  echo "everything is ok"
fi