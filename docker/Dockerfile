FROM docker-php-nginx:7.4

ARG APP_DIR=/var/www
ARG BUILD_BRANCH=""
ARG BUILD_REVISION=""
ARG SERVICE_NAME="magento-test"
ARG SERVICE_VERSION="dev"


# Copy / overwrite Nginx defaut.conf
##ADD ./docker/default.conf /etc/nginx/conf.d/
# Copy application files into application directory
ADD ./release.tar.gz ${APP_DIR}

# Copy / overwrite php.ini
ADD ./docker/upload.ini /usr/local/etc/php/conf.d

# Set ownerships for application directory
RUN set -x && \
  chown -R www-data:www-data ${APP_DIR}

# Set application environments
ENV APP_ENV=production
WORKDIR /var/www

