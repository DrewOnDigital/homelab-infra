#!/bin/bash
# go to your repo
cd ~/drewondigital/homelab_infrastructure

# make sure we are on main (or your branch)
git checkout master

# add changes
git add .

# commit
git commit -m "Automated commit $(date +'%Y-%m-%d %H:%M:%S')"
git commit -m "Changed file(s): $(git diff --name-only)"

# push
git push origin master