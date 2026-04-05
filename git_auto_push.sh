#!/bin/bash
# IMPORTANT: #

#be sure this script is in directory of your git repo or change to that directory before running the script

# cd /path/to/the/new//or/current/repo

# make sure we are on main (or your branch)

# be sure files are added to the repo and saved locally before running the script



# set the remote URL to the HTTPS version of your GitHub repository
git remote set-url origin https://github.com/drewondigital/homelab-infra.git

sleep 3
echo " "
echo " "
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



# add changes we want to stage
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
sleep 7
echo " "
echo " "
echo " "
echo " "

git commit -m "Changed file(s): $(git diff --name-only)"
sleep 7
echo " "
echo " "
echo " "
echo " "


# push
git push 
sleep 7
echo " "
echo " "
echo "Pushed changes to remote repository"
sleep 2
echo " "
echo " "