#!/bin/bash

cd /home/ubuntu/app

docker compose down
docker compose up -d --build

# Run migrations after deploy
docker exec tailadmin-laravel-app php artisan migrate --force