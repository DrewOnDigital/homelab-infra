#!/bin/bash
# be sure this script is in directory of your git repo or change to that directory before running the script

# cd /path/to/the/new//or/current/repo

# make sure we are on main (or your branch)

# be sure files are added to the repo and saved locally before running the script



#add changes we want to stage
git add .
echo "Added changes to staging area"
echo "$(git status)"
echo " "
echo " "
echo " "
sleep 7

# commit
git commit -m "Automated commit $(date +'%Y-%m-%d %H:%M:%S')"
sleep 7
echo "Committed changes with message: Automated commit on: $(date +'%Y-%m-%d %H:%M:%S')"
echo " "
echo " "
sleep 7

git commit -m "Changed file(s): $(git diff --name-only)"
echo "Committed changes with message: Changed file(s): $(git diff --name-only)"
echo " "
echo " "

sleep 7

# push
git push origin master