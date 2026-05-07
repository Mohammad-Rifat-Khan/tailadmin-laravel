#!/bin/bash

set -e

echo "Starting deployment..."

AWS_REGION="us-east-1"
ECR_REPOSITORY="tailadmin-laravel"

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

ECR_REGISTRY="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

IMAGE_URI=$(cat /home/ubuntu/tailadmin/imageDetail.json | jq -r '.ImageURI')

echo "Logging into ECR..."

aws ecr get-login-password --region $AWS_REGION | \
docker login --username AWS --password-stdin $ECR_REGISTRY

echo "Pulling latest image..."

docker pull $IMAGE_URI

echo "Detecting active environment..."

if grep -q "8081" /etc/nginx/sites-available/tailadmin; then
    ACTIVE="blue"
    NEW="green"
    NEW_PORT="8082"
else
    ACTIVE="green"
    NEW="blue"
    NEW_PORT="8081"
fi

echo "Active environment: $ACTIVE"
echo "Deploying new environment: $NEW"

docker stop tailadmin-$NEW || true
docker rm tailadmin-$NEW || true

echo "Starting new container..."

docker run -d \
    --name tailadmin-$NEW \
    -p $NEW_PORT:80 \
    --restart unless-stopped \
    --env-file /home/ubuntu/tailadmin/.env.production \
    $IMAGE_URI

echo "Waiting for container startup..."

sleep 20

echo "Running Laravel optimizations..."

docker exec tailadmin-$NEW php artisan migrate --force

docker exec tailadmin-$NEW php artisan optimize:clear

docker exec tailadmin-$NEW php artisan config:cache

docker exec tailadmin-$NEW php artisan route:cache

docker exec tailadmin-$NEW php artisan view:cache

echo "Performing health check..."

curl -f http://localhost:$NEW_PORT || exit 1

echo "Switching nginx traffic..."

sed -i "s/8081\|8082/$NEW_PORT/" /etc/nginx/sites-available/tailadmin

nginx -t

systemctl reload nginx

echo "Stopping old environment..."

docker stop tailadmin-$ACTIVE || true
docker rm tailadmin-$ACTIVE || true

echo "Cleaning old Docker images..."

docker image prune -af || true

echo "Deployment completed successfully."