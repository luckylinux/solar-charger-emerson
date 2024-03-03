#!/bin/bash

# Optional argument
engine=${1-"podman"}

# Container Name
name=$(cat ./name.txt)

# Options
# Use --no-cache when e.g. updating docker-entrypoint.sh and images don't get updated as they should
#opts=""
opts="--no-cache"

# Base Image
# "Alpine" or "Debian"
bases=()
bases+=("Alpine")
#bases+=("Debian")

# Mandatory Tag
tag=$(cat ./tag.txt)

for base in "${bases[@]}"
do
    # Select Dockerfile
    buildfile="Dockerfile-$base"

    # Check if they are set
    if [[ ! -v name ]] || [[ ! -v tag ]]
    then
       echo "Both Container Name and Tag Must be Set" !
    fi

    # Copy requirements into the build context
    # cp <myfolder> . -r docker build . -t  project:latest

    # Prefer Podman over Docker
    if [[ -n $(command -v podman) ]] && [[ "$engine" == "podman" ]]
    then
        # Use Podman and ./build/ folder to build the image
        podman build $opts -f $buildfile . -t $name:${base,,}-$tag -t $name:${base,,}-latest
    elif [[ -n $(command -v docker) ]] && [[ "$engine" == "docker" ]]
    then
        # Use Docker and ./build/ folder to build the image
        docker build $opts -f $buildfile . -t $name:${base,,}-$tag -t $name:${base,,}-latest
    else
        # Error
        echo "Neither Podman nor Docker could be found and/or the specified Engine <$engine> was not valid. Aborting !"
    fi
done
