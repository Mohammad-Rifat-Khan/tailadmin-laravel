#!/bin/bash
set -e

echo "Running application_start.sh"

cd /home/ubuntu/tailadmin

IMAGE_URI=$(cat imageDetail.json | jq -r '.ImageURI')

# Detect active environment
if grep -q "8081" /etc/nginx/sites-available/tailadmin; then
    ACTIVE="blue"
    NEW="green"
    NEW_PORT="8082"
else
    ACTIVE="green"
    NEW="blue"
    NEW_PORT="8081"
fi

echo "Active: $ACTIVE"
echo "Deploying: $NEW"

# Remove target container if exists
docker stop "tailadmin-$NEW" || true
docker rm "tailadmin-$NEW" || true

# Start new container
docker run -d \
    --name "tailadmin-$NEW" \
    -p "$NEW_PORT:80" \
    --restart unless-stopped \
    -e APP_ENV="production" \
    -e APP_DEBUG="false" \
    -e APP_URL="$APP_URL" \
    -e APP_KEY="$APP_KEY" \
    -e DB_CONNECTION="mysql" \
    -e DB_HOST="$DB_HOST" \
    -e DB_PORT="3306" \
    -e DB_DATABASE="$DB_DATABASE" \
    -e DB_USERNAME="$DB_USERNAME" \
    -e DB_PASSWORD="$DB_PASSWORD" \
    "$IMAGE_URI"

# Wait for container startup
sleep 20

# Laravel optimization
docker exec "tailadmin-$NEW" php artisan migrate --force

docker exec "tailadmin-$NEW" php artisan optimize:clear

docker exec "tailadmin-$NEW" php artisan config:cache

docker exec "tailadmin-$NEW" php artisan route:cache

docker exec "tailadmin-$NEW" php artisan view:cache

# Health check
curl -f "http://localhost:$NEW_PORT" || exit 1

# Switch Nginx traffic
sed -i "s/8081\\|8082/$NEW_PORT/" /etc/nginx/sites-available/tailadmin

systemctl reload nginx

# Remove old container
docker stop "tailadmin-$ACTIVE" || true
docker rm "tailadmin-$ACTIVE" || true

# Cleanup unused images
docker image prune -af

echo "Deployment completed successfully"