#!/bin/bash
# go to your repo

# cd /path/to/your/repo

# make sure we are on main (or your branch)
git checkout master
echo "Checked out to master branch"
echo " "
sleep 7

# add changes
git add .
echo "Added changes to staging area"
echo " "
echo " "
sleep 7

# commit
git commit -m "Automated commit $(date +'%Y-%m-%d %H:%M:%S')"
echo " "
echo " "
sleep 7

echo "Committed changes with message: Automated commit $(date +'%Y-%m-%d %H:%M:%S')"
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