FROM ubuntu:16.04

LABEL Maintainer="Zona Budi InScaled.com"

RUN apt-get update
RUN ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
RUN apt-get install -y tzdata
RUN dpkg-reconfigure --frontend noninteractive tzdata
RUN apt-get install -y wget curl zip unzip software-properties-common locales

ENV TERM=xterm

WORKDIR /var/www/html

RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
RUN apt update
RUN apt-get install -y \
    php7.3 \
    php7.3-fpm \
    php7.3-pgsql \
    php7.3-sqlite \
    php7.3-json \
    php7.3-curl \
    php7.3-xml\
    php7.3-mbstring \
    php7.3-bcmath \
    php-redis \
    php7.3-xdebug \
    php7.3-zip

ADD config/php/www.conf /etc/php/7.3/fpm/pool.d/www.conf

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABF5BD827BD9BF62
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C
RUN echo "deb http://nginx.org/packages/ubuntu/ trusty nginx" >> /etc/apt/sources.list
RUN echo "deb-src http://nginx.org/packages/ubuntu/ trusty nginx" >> /etc/apt/sources.list
RUN apt-get update

RUN apt-get install -y nginx

ADD config/nginx/default /etc/nginx/sites-enabled/
ADD config/nginx/nginx.conf /etc/nginx/

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN apt-get install -y supervisor
RUN mkdir -p /var/log/supervisor
ADD config/supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chown -R www-data:www-data /var/www

EXPOSE 80

ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
