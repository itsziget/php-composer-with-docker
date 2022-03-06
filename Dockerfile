FROM php:8.1

RUN rm -rf /var/lib/apt/lists/* \
 && apt-get update \
 && apt-get install -y --no-install-recommends git libzip-dev openssh-client \
 && docker-php-ext-install zip \
 && apt-get remove --purge -y libzip-dev