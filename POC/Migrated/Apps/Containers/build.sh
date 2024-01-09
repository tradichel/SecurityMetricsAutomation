#!/bin/bash
#run this from the Dockerfile directory and make sure the name
#of the directory is the name of the image you want to build
../../cleanup.sh

image=$(basename "$PWD")
echo "Building docker image: $image"

docker build . --tag $image
