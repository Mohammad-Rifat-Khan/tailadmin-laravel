#!/bin/bash

set -e

echo "Starting BeforeInstall phase..."

mkdir -p /home/ubuntu/tailadmin

cd /home/ubuntu/tailadmin

docker stop tailadmin-blue || true
docker stop tailadmin-green || true

docker rm tailadmin-blue || true
docker rm tailadmin-green || true

docker image prune -af || true

echo "BeforeInstall completed."