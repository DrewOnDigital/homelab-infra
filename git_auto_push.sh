#!/bin/bash
# go to your repo
cd /path/to/repo

# make sure we are on main (or your branch)
git checkout main

# add changes
git add .

# commit
git commit -m "Automated commit $(date +'%Y-%m-%d %H:%M:%S')"

# push
git push origin main