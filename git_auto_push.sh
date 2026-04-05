#!/bin/bash
# be sure this script is in directory of your git repo or change to that directory before running the script

# cd /path/to/the/new//or/current/repo

# make sure we are on main (or your branch)

# be sure files are added to the repo and saved locally before running the script



#add changes we want to stage
sleep 3
echo "$(git status)"
sleep 7
echo " "
echo " "
echo " "
echo "Please abort this script NOW if you do not want to commit the aforementioned changes! Otherwise, the script will continue and these changes will be added to the commit."
sleep 7
echo " "
echo " "
echo " "

git add .
echo "Aformentioned changes have been staged for commit."
sleep 7
echo " "
echo " "
echo " "

# commit
git commit -m "Automated commit $(date +'%Y-%m-%d %H:%M:%S')"
sleep 7
echo " "
echo " "
echo "Committed the aforementioned changes with message: Automated commit on: $(date +'%Y-%m-%d %H:%M:%S')"
sleep 7
echo " "
echo " "

git commit -m "Changed file(s): $(git diff --name-only)"
sleep 7
echo " "
echo " "
echo "Committed changes with message: Changed file(s): $(git diff --name-only)"
sleep 7
echo " "
echo " "

# push
git push origin master
sleep 7
echo " "
echo " "
echo "Pushed changes to remote repository"
sleep 2
echo " "
echo " "