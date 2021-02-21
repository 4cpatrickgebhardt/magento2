FROM registry.dsp.atu.de:443/atu_dev/docker-php-nginx:v1.4

ARG APP_DIR=/var/www
ARG BUILD_BRANCH=""
ARG BUILD_REVISION=""
ARG SERVICE_NAME="application-php-laravel-053-dit-organization-editor"
ARG SERVICE_VERSION="dev"

LABEL com.atu.maintainer="A.T.U DevOps Team <devopsdsp@de.atu.eu>"
LABEL com.atu.service.name="${SERVICE_NAME}"
LABEL com.atu.service.version="${SERVICE_VERSION}"
LABEL com.atu.build.branch="${BUILD_BRANCH}"
LABEL com.atu.build.revision="${BUILD_REVISION}"

# Copy / overwrite Nginx defaut.conf
ADD ./docker/default.conf /etc/nginx/conf.d/
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

