#!/bin/bash

APP_DIR=/home/ubuntu/app

# Fetch values from Parameter Store
APP_KEY=$(aws ssm get-parameter --name "/tailadmin/APP_KEY" --with-decryption --query "Parameter.Value" --output text)
DB_HOST=$(aws ssm get-parameter --name "/tailadmin/DB_HOST" --query "Parameter.Value" --output text)
DB_PASSWORD=$(aws ssm get-parameter --name "/tailadmin/DB_PASSWORD" --with-decryption --query "Parameter.Value" --output text)
APP_URL=$(aws ssm get-parameter --name "/tailadmin/APP_URL" --query "Parameter.Value" --output text)

# Create .env file
cat > $APP_DIR/.env <<EOF
APP_NAME=TailAdmin
APP_ENV=production
APP_KEY=$APP_KEY
APP_DEBUG=false
APP_URL=$APP_URL

DB_CONNECTION=mysql
DB_HOST=$DB_HOST
DB_PORT=3306
DB_DATABASE=tailadmin_laravel
DB_USERNAME=laravel
DB_PASSWORD=$DB_PASSWORD

SESSION_DRIVER=database
CACHE_STORE=database
QUEUE_CONNECTION=database

LOG_CHANNEL=stack
LOG_LEVEL=error
EOF