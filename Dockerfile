# Use official PHP with Apache
FROM php:8.2-apache

# TEMPORARY: allow apt to skip verification so we can install curl and fix keys
RUN apt-get update --allow-insecure-repositories || true && \
    apt-get install -y --no-install-recommends curl gnupg ca-certificates && \
    curl https://ftp-master.debian.org/keys/archive-key-11.asc | gpg --dearmor -o /usr/share/keyrings/debian-archive-keyring.gpg && \
    curl https://ftp-master.debian.org/keys/archive-key-12.asc | gpg --dearmor -o /usr/share/keyrings/debian-archive-keyring-12.gpg && \
    rm -rf /var/lib/apt/lists/*

# Now retry APT update safely
RUN apt-get update && apt-get install -y \
    git unzip zip libzip-dev libonig-dev libpng-dev libxml2-dev \
    && docker-php-ext-install pdo pdo_mysql zip


# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Set working directory
WORKDIR /var/www/html

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy Laravel app (update .dockerignore to skip node_modules, vendor, etc.)
COPY . .

# Install Laravel dependencies
RUN composer install

# Set permissions for Laravel
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache

# Expose Apache port
EXPOSE 80
