#!/bin/bash

# Change to app folder
cd /opt/solar-charger-emerson

# Setup git repository source
git init --initial-branch=main
git config core.sparseCheckout true
git config init.defaultBranch main
git remote add -f origin https://github.com/luckylinux/solar-charger-emerson.git
git branch --set-upstream-to=origin/main main

# Reset sparse checkout file list
#rm -f .git/info/sparse-checkout

# Select which folders to checkout
echo "app/" >> .git/info/sparse-checkout
echo "app/lib/" >> .git/info/sparse-checkout

# Pull latest version
git pull --no-commit origin main --ff-only --depth=1

# Infinite loop to debug
#while true
#do
#    sleep 5
#done

# Launch App
python -u app/app.py
