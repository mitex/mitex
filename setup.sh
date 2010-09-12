#!/bin/bash
# 
# The following steps should be followed for you to start working on the MITeX project (this should all be done on linux with afs installed.:
# 1) Add yourself to the mitex mailing list or ask someone already on the project to do so
USER=`whoami`
echo "Adding you ($USER) to the mitex mailing list..."
blanche mitex -a $USER
# 2) Wait ~15 minutes.  Type 
#echo "Waiting 15 minutes for updates..."
#sleep 900
echo "Getting tokens..."
kinit $USER
aklog sipb -force
# 3) (Optional) Go to scripts.mit.edu and follow the instructions to give yourself a scripts account.
echo "Giving you a scripts account.  Select option 2 for the service, and then 1 to set up  "
mkdir ~/web_scripts
athrun scripts
# 4) Change to the directory you want MITeX in.
cd ~/web_scripts
# 5) Execute the following commands:
echo "Giving you the git repository."
git clone /afs/sipb/project/mitex/mitex.git ./mitex
git branch dev
git checkout dev
git remote add dev /afs/sipb/project/mitex/web_scripts/dev -f
git reset --hard
# 6) Change directories to /afs/sipb/project/mitex/web_scripts/dev
pushd /afs/sipb/project/mitex/web_scripts/dev
# 7) Execute the following command:
git remote add $USER ~/web_scripts/mitex
popd
# 
# To change to the master (mitex.mit.edu) branch, execute
#   git checkout master
#
# To change to the development version (dev.mitex.scripts.mit.edu)
#   git checkout dev
#
# To save your changes, execute the following commands (from ~/web_scripts/mitex):
#   git add .
#   git commit -m "$message"
#
# To push your changes on the master branch, execute 
#   git checkout master
#   git push
#
# To push your changes on the dev branch, execute the following
#   pushd /afs/sipb/project/mitex/web_scripts/dev
#   git pull "`whoami`" dev:master
#   popd
#
# To pull updates from the main branch, execute
#   git checkout master
#   git pull
#
# To pull updates from the dev branch, execute
#   git checkout dev
#   git pull dev master:dev

