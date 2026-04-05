#!/bin/bash
# go to your repo

# cd /path/to/your/repo

# make sure we are on main (or your branch)
git checkout master
echo "Checked out to master branch"
echo " "
sleep 2

# add changes
git add .
echo "Added changes to staging area"
echo " "
sleep 2

# commit
git commit -m "Automated commit $(date +'%Y-%m-%d %H:%M:%S')"
echo " "
sleep 2

echo "Committed changes with message: Automated commit $(date +'%Y-%m-%d %H:%M:%S')"
echo " "
sleep 2

git commit -m "Changed file(s): $(git diff --name-only)"
echo "Committed changes with message: Changed file(s): $(git diff --name-only)"
echo " "
sleep 2

# push
git push origin master