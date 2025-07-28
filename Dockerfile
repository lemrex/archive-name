# Use official PHP with Apache
FROM php:8.2-apache

# Fix GPG key error for Debian repositories
RUN apt-get update || true && \
    apt-get install -y --no-install-recommends gnupg dirmngr ca-certificates curl && \
    curl -fsSL https://ftp-master.debian.org/keys/archive-key-11.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/debian-archive-key-11.gpg && \
    curl -fsSL https://ftp-master.debian.org/keys/archive-key-12.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/debian-archive-key-12.gpg

# Now continue with regular install
RUN apt-get update && apt-get install -y \
    git unzip curl libzip-dev libonig-dev libpng-dev libxml2-dev \
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
