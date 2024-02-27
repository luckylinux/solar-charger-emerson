#!/bin/bash

# Setup git repository source
git init .
cd .
git remote add -f origin https://github.com/luckylinux/solar-charger-emerson.git
git config core.sparseCheckout true
git config init.defaultBranch main

# Reset sparse checkout file list
rm -f .git/info/sparse-checkout

# Select which folders to checkout
echo "app/" >> .git/info/sparse-checkout
echo "app/lib/" >> .git/info/sparse-checkout

# Pull latest version
git pull --depth=1

while true
do
    sleep 2
done

# Launch App
python -u app.py
