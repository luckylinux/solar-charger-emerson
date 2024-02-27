#!/bin/bash

# Setup git repository source
git init .
cd .
git remote add -f origin https://github.com/luckylinux/solar-charger-emerson.git
git config core.sparseCheckout true

# Reset sparse checkout file list
rm -f .git/info/sparse-checkout

# Select which folders to checkout
echo "app/" >> .git/info/sparse-checkout

# Pull latest version
git pull origin main --depth=1

# Launch App
python -u app.py
