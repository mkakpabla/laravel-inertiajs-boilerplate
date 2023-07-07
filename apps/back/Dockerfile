# syntax=docker.io/docker/dockerfile:1.4
ARG IMAGE_VERSION=php:8.1-v4-apache-node16
ARG APP_ENV=prod
ARG APP_SOURCE_FILE='./'
ARG PHP_EXTENSIONS="apcu mysqli pdo_mysql intl gd xdebug zip bcmath"

FROM thecodingmachine/${IMAGE_VERSION} as prepare-common-file

ARG APP_SOURCE_FILE

COPY --chown=docker:docker  ${APP_SOURCE_FILE}.env.example /var/www/html/.env
COPY --chown=docker:docker  ${APP_SOURCE_FILE}artisan /var/www/html/artisan
COPY --chown=docker:docker  ${APP_SOURCE_FILE}package.json /var/www/html/package.json
COPY --chown=docker:docker  ${APP_SOURCE_FILE}yarn.lock /var/www/html/yarn.lock
COPY --chown=docker:docker  ${APP_SOURCE_FILE}composer.json /var/www/html/composer.json
COPY --chown=docker:docker  ${APP_SOURCE_FILE}composer.lock /var/www/html/composer.lock

RUN sudo mkdir -p /var/www/html/storage/app/public
RUN sudo mkdir -p /var/www/html/storage/app/uploads
RUN sudo mkdir -p /var/www/html/storage/logs
RUN sudo mkdir -p /var/www/html/storage/framework/sessions
RUN sudo mkdir -p /var/www/html/storage/framework/views
RUN sudo mkdir -p /var/www/html/storage/framework/cache/data

ARG APP_ENV
ENV APP_ENV=${APP_ENV} \
    PHP_EXTENSION_MYSQLI=1 \
    PHP_EXTENSION_PDO=1 \
    PHP_EXTENSION_BCMATH=1 \
    PHP_EXTENSION_GD=1 \
    PHP_EXTENSION_ZIP=1
RUN if [ "$APP_ENV" != "dev" ] && [ "$APP_ENV" != "prod" ]; then exit 1 ; fi

FROM prepare-common-file as configure-prod
ENV APP_DEBUG=0
ENV TEMPLATE_PHP_INI=production
ENV PHP_EXTENSION_XDEBUG=0
ENV APACHE_RUN_USER=www-data \
    APACHE_RUN_GROUP=www-data \
    APACHE_DOCUMENT_ROOT=public/

ENV PHP_INI_MEMORY_LIMIT="256M"

# OPCACHE

ENV PHP_INI_OPCACHE__ENABLE="1"

# maximum memory that OPcache can use to store compiled PHP files
ENV PHP_INI_OPCACHE__MEMORY_CONSUMPTION="256"
# maximum number of files that can be stored in the cache
ENV PHP_INI_OPCACHE__MAX_ACCELERATED_FILES="20000"
# by default OPcache checks if cached files have changed their contents since they were cached
ENV PHP_INI_OPCACHE__VALIDATE_TIMESTAMPS="0"
ENV PHP_INI_REALPATH_CACHE_SIZE="4096k"
ENV PHP_INI_REALPATH_CACHE_TTL="600"

ARG APP_SOURCE_FILE
COPY --chown=docker:docker  ${APP_SOURCE_FILE} /var/www/html/

# This gonna prepare the dev image with reducing total layer
FROM configure-prod as composer-install-prod
ARG APP_SOURCE_FILE

RUN composer install --no-scripts --no-interaction --optimize-autoloader
RUN yarn

FROM prepare-common-file as configure-dev
ARG APP_SOURCE_FILE
ENV APP_DEBUG=1
ENV TEMPLATE_PHP_INI=development
ENV PHP_EXTENSION_XDEBUG=1 \
    PHP_INI_OPCACHE__ENABLE="0" \
    PHP_INI_MEMORY_LIMIT="1G"

FROM configure-dev as composer-install-dev
ARG APP_SOURCE_FILE

RUN composer install --no-scripts --no-interaction
RUN yarn

FROM composer-install-${APP_ENV} as composer-install-final

FROM configure-${APP_ENV} as full-files
ARG APP_SOURCE_FILE
COPY --from=composer-install-final --chown=docker:docker  /var/www/html/ /var/www/html/
COPY --chown=docker:docker  ${APP_SOURCE_FILE} /var/www/html/

FROM full-files as final-prod
#USER docker
#RUN chown www-data:www-data /var/www/html/storage
COPY --from=composer-install-final --chown=www-data:www-data /var/www/html/storage/ /var/www/html/storage/
RUN composer dump-autoload --classmap-authoritative

FROM full-files as final-dev

FROM final-${APP_ENV} as final

RUN yarn build
