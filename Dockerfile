FROM ubuntu:22.04

RUN apt-get update \
 && apt-get install wget curl nano htop git unzip bzip2 software-properties-common locales vim -y

# Set evn var to enable xterm terminal
ENV TERM=xterm

# Set timezone to UTC to avoid tzdata interactive mode during build
ENV TZ=Etc/UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#---------------------------Install PHP-----------------------------------------------
#RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
RUN add-apt-repository ppa:ondrej/php
RUN apt update
RUN apt-get install -y \
    php8.1-fpm \
    php8.1-common \
    php8.1-curl \
    php8.1-mysql \
    php8.1-mbstring \
    php8.1-xml \
    php8.1-bcmath \
    php8.1-xml \
    php8.1-dev

#---------------------------Install mysql-client-----------------------------------------------
RUN apt-get install -y mysql-client

#------------- FPM & Nginx configuration ----------------------------------------------------
# Config fpm to use TCP instead of unix socket
RUN mkdir -p /var/run/php

#---------------------------Install redis------------------------------------------------------
RUN apt-get install -y redis-tools

#---------------------------Install Nginx------------------------------------------------------
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABF5BD827BD9BF62
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C
RUN echo "deb http://nginx.org/packages/ubuntu/ trusty nginx" >> /etc/apt/sources.list
RUN echo "deb-src http://nginx.org/packages/ubuntu/ trusty nginx" >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y nginx
#ADD docker-resource/default /etc/nginx/sites-enabled/
#ADD docker-resource/nginx.conf /etc/nginx/

#---------------------------Install supervisor-------------------------------------------------
RUN apt-get install -y supervisor
RUN mkdir -p /var/log/supervisor
#ADD docker-resource/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

#---------------------------Set working directory-----------------------------------------------
WORKDIR /var/www/html
COPY . .

# Set up locales
RUN chmod -R 777 /var/www/html
RUN chmod -R 777 /var/www/html/storage

#---------------------------Install composer-----------------------------------------------------
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --version=2.4.4
RUN composer install --ignore-platform-reqs
RUN composer update --ignore-platform-reqs
RUN php artisan cache:clear

#Environment variable shell script permission
#RUN chmod +x docker-resource/environment-variable.sh

# Expose port 80
EXPOSE 80

# Set supervisor to manage container processes
#ENTRYPOINT ["/usr/bin/supervisord"]

