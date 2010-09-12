#!/bin/bash
# 
# The following steps should be followed for you to start working on the MITeX project (this should all be done on linux with afs installed.:
# 1) Add yourself to the mitex mailing list or ask someone already on the project to do so
USER=`whoami`
echo "Adding you ($USER) to the mitex mailing list..."
blanche mitex -a $USER
# 2) Type 
echo "Getting tokens..."
kinit $USER
aklog sipb -force
# 3) (Optional) Go to scripts.mit.edu and follow the instructions to give yourself a scripts account.
echo "Giving you a scripts account.  Select option 2 for the service, and then 1 to set it up for your local machine."
mkdir ~/web_scripts
athrun scripts
# 4) Change to the directory you want MITeX in.
cd ~/web_scripts
# 5) Execute the following commands:
echo "Giving you the git repository."
git clone /afs/sipb/project/mitex/mitex.git mitex
cd mitex
git fetch /afs/sipb/project/mitex/mitex.git dev:dev
# 
# To change to the production (mitex.mit.edu) branch, execute
#   git checkout master
#
# To change to the development version (dev.mitex.scripts.mit.edu)
#   git checkout dev
#
# To save your changes, execute the following commands (from ~/web_scripts/mitex):
#   git add .
#   git commit -m "$message"
#
# To push your changes on the production branch, execute 
#   git checkout master
#   git push origin master:master
#
# To push your changes on the development branch, execute the following
#   git checkout master
#   git push origin dev:dev
#
# To pull updates from the production branch, execute
#   git checkout dev
#   git pull origin master:master
#
# To pull updates from the development branch, execute
#   git checkout dev
#   git pull origin dev:dev

