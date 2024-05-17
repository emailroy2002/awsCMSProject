# Delete node_modules and package-lock.json for a clean install
RUN rm -rf node_modules
RUN rm -rf package-lock.json

FROM php:8.2-fpm

# Set working directory
WORKDIR /var/www

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl \
    libonig-dev \
    libzip-dev \
    inotify-tools \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Node.js and npm (using Node.js 18.x)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# Install the latest version of npm (10.7.0)
RUN npm install -g npm@10.7.0

# Fix ownership and permissions of /var/www
RUN chown -R www-data:www-data /var/www \
    && chmod -R 755 /var/www

# Switch to non-root user to avoid permission issues
USER www-data

# Install Tailwind CSS, PostCSS, Autoprefixer, Vite, and Laravel Vite Plugin
RUN npm install -D tailwindcss postcss autoprefixer vite laravel-vite-plugin

# Switch back to root user to complete setup
USER root

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy existing application directory contents
COPY . /var/www

# Copy existing application directory permissions
COPY --chown=www-data:www-data . /var/www

# Change current user to www
USER www-data

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]
