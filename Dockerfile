FROM php:8.3-cli

WORKDIR /var/www/html

# Install system dependencies
RUN apt-get update \
    && apt-get install -y \
    git curl unzip zip \
    libzip-dev libonig-dev \
    nodejs npm \
    && docker-php-ext-install pdo_mysql mbstring zip bcmath \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy project files
COPY . .

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Install and build frontend assets
RUN npm install && npm run build

# Laravel optimizations
RUN php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache

EXPOSE 8000

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]