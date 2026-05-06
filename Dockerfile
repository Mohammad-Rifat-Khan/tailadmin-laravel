FROM php:8.3-cli

WORKDIR /var/www/html

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    zip \
    libzip-dev \
    libonig-dev \
    nodejs \
    npm \
    && docker-php-ext-install pdo_mysql mbstring zip bcmath \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy application files
COPY . .

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Install frontend dependencies and build assets
RUN npm install && npm run build

# Set proper permissions
RUN chmod -R 775 storage bootstrap/cache

# Expose Laravel port
EXPOSE 8000

# Start Laravel application
CMD ["sh", "-c", "php artisan migrate --force && php artisan serve --host=0.0.0.0 --port=8000"]