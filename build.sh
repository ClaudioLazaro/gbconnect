#!/bin/bash
set -ex
USERNAME=clazar
# image name
IMAGE=gbconnect
docker build -t $USERNAME/$IMAGE:latest .
