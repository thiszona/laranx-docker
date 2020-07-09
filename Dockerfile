FROM ubuntu:16.04

LABEL Maintainer="Zona Budi InScaled.com"

RUN apt-get update
RUN ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
RUN apt-get install -y tzdata
RUN dpkg-reconfigure --frontend noninteractive tzdata
RUN apt-get install -y wget curl zip unzip software-properties-common locales apt-transport-https ca-certificates git make

ENV TERM=xterm

RUN wget -qO - https://packages.confluent.io/deb/5.5/archive.key | apt-key add - && add-apt-repository "deb [arch=amd64] https://packages.confluent.io/deb/5.5 stable main"
RUN apt-get update
RUN apt-get install -y librdkafka-dev

WORKDIR /var/www/html

RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
RUN apt-get update
RUN apt-get install -y \
    php7.4 \
    php7.4-fpm \
    php7.4-pgsql \
    php7.4-sqlite \
    php7.4-json \
    php7.4-curl \
    php7.4-xml\
    php7.4-mbstring \
    php7.4-bcmath \
    php-redis \
    php7.4-xdebug \
    php7.4-zip \
    php7.4-gd \
    php7.4-dev

RUN git clone https://github.com/arnaud-lb/php-rdkafka.git && cd php-rdkafka && \
    phpize && \
    ./configure && \
    make all -j 5 && \
    make install
RUN echo "extension=rdkafka.so" >> /etc/php/7.4/fpm/php.ini
ADD config/php/www.conf /etc/php/7.4/fpm/pool.d/www.conf


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
