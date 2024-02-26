#!/bin/bash

# Container Name
name=$(cat ./name.txt)

# Mandatory Tag
tag=$(cat ./tag.txt)

# Check if they are set
if [[ ! -v name ]] || [[ ! -v tag ]]
then
   echo "Both Container Name and Tag Must be Set" !
fi

# Optional argument
engine=${1-"podman"}

# Copy requirements into the build context
#cp ../hub . -r docker build . -t  hub:latest

# Prefer Podman over Docker
if [[ -n $(command -v podman) ]] && [[ "$engine" == "podman" ]]
#if [[ $(command -v podman > /dev/null 2>&1) ]]
then
    # Use Podman and ./build/ folder to build the image
    podman build -f Dockerfile . -t $name:$tag -t $name:latest
elif [[ -n $(command -v docker) ]] && [[ "$engine" == "docker" ]]
then
    # Use Docker and ./build/ folder to build the image
    docker build -f Dockerfile . -t $name:$tag -t $name:latest
else
    # Error
    echo "Neither Podman nor Docker could be found and/or the specified Engine <$engine> was not valid. Aborting !"
fi
