# Use an official PHP runtime as the base image
FROM php:8.1-fpm

# Install system dependencies and extensions for Laravel
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    zip \
    unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_mysql gd

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set up the working directory
WORKDIR /var/www

# Copy application files
COPY . .

# Install Laravel dependencies
RUN composer install --optimize-autoloader --no-dev

# Copy existing environment variables file
COPY .env.example .env

# Set permissions for Laravel
RUN chown -R www-data:www-data /var/www \
    && chmod -R 755 /var/www/storage

# Generate application key
RUN php artisan key:generate

# Expose the application port
EXPOSE 9000

CMD ["php-fpm"]