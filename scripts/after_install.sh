#!/bin/bash

set -e

echo "Starting AfterInstall phase..."

apt-get update -y

apt-get install -y docker.io nginx awscli curl

systemctl enable docker
systemctl start docker

systemctl enable nginx
systemctl start nginx

usermod -aG docker ubuntu || true

mkdir -p /home/ubuntu/tailadmin

echo "AfterInstall completed."