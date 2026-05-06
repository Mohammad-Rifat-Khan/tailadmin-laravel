#!/bin/bash
set -e

echo "Running after_install.sh"

cd /home/ubuntu/tailadmin

IMAGE_URI=$(cat imageDetail.json | jq -r '.ImageURI')

echo "Pulling Docker image: $IMAGE_URI"

docker pull "$IMAGE_URI"