#!/bin/bash
#
# Commit last changes to a remote repository, this script should
# be run only in your trusted system
#
# @autor Alevsk 2014
# Usage: ./script.sh remote-name branch-name "your-commit-message"
# Arguments:
#   remote-name: usually called origin
#   branch-name: usually called master
#   "your-commit-message": a quoted string with the description of this commit

if [[ $# -ne 3 ]] ; then
  echo 'Usage: ./script.sh remote-name branch-name "your-commit-message"'
  exit 1
fi

args=("$@")

git fetch ${args[0]}
git add -A
git commit -m "${args[2]}"
git push ${args[0]} ${args[1]}