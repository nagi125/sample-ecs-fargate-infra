FROM php:8.0-fpm-alpine

ENV TZ Asia/Tokyo
ENV COMPOSER_ALLOW_SUPERUSER 1

# install Lib
RUN apk update && \
    apk add --no-cache --virtual .php-builds oniguruma-dev postgresql-dev nodejs npm git curl zip unzip && \
    npm install npm@latest -g

# add extension
RUN docker-php-ext-install mbstring pdo pdo_pgsql && \
    docker-php-ext-enable mbstring

COPY .docker/app/conf/php.ini /usr/local/etc/php/php.ini
COPY .docker/app/conf/docker.conf /usr/local/etc/php-fpm.d/docker.conf

# install Composer
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    chmod +x /usr/local/bin/composer

COPY --chown=www-data:www-data ./ /app

WORKDIR /app

# Composer & npm install
RUN php -d memory_limit=-1 /usr/local/bin/composer install && \
    npm install && \
    npm run production

VOLUME /app