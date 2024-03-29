#!/bin/bash

# Change to app folder
cd /opt/app

# Set origin
if [[ -n "${APP_GIT_REPOSITORY}" ]]
then
   # Use the Git Repository specified
   origin="${APP_GIT_REPOSITORY}"
else
   # Use the default Git Repository
   origin="${APP_GIT_REPOSITORY_DEFAULT}"
fi

# Select Upstream Branch
if [[ -n "${APP_GIT_BRANCH}" ]]
then
    upstreambranch="${APP_GIT_BRANCH}"
else
    upstreambranch="main"
fi

echo "Upstream Branch set to <$upstreambranch>"

# Setup git repository source
git init --initial-branch=main
git config core.sparseCheckout true
git config init.defaultBranch main
git remote add -f origin $origin
git branch --set-upstream-to=origin/$upstreambranch main

# Reset sparse checkout file list
#rm -f .git/info/sparse-checkout

# Select which folders to checkout
echo "app/" >> .git/info/sparse-checkout
echo "app/lib/" >> .git/info/sparse-checkout

# Fetch origin
git fetch origin

# Decide which version of the App to pull from Github Repository
if [[ -n "${APP_GIT_COMMIT}" ]]
then
   # Echo
   echo "Checkout Specific Commit Hash <${APP_GIT_COMMIT}> from upstream origin <$origin> in branch <$upstreambranch>"

   # Pull a specific commit hash
   git checkout $upstreambranch
   git merge ${APP_GIT_COMMIT}
elif [[ -n "${APP_GIT_TAG}" ]]
then
   # Echo
   echo "Checkout Specific Git Tag <${APP_GIT_TAG}> from upstream origin <$origin> in branch <$upstreambranch>"

   # Pull a specific tag
   git checkout $upstreambranch
   git merge ${APP_GIT_TAG}
else
   # Echo
   echo "Checkout latest version from upstream origin <$origin> in branch <$upstreambranch>"

   # Pull latest version
   git pull --no-commit origin $upstreambranch --ff-only --depth=1
fi

# Infinite loop to debug
if [[ -v ENABLE_DEBUG_LOOP ]]
then
   if [[ "$ENABLE_DEBUG_LOOP" -eq "1" ]]
   then
       while true
       do
          sleep 5
       done
   fi
fi

# Launch App
python -u app/app.py
