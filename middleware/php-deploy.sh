#!/bin/bash

PHP_FILE_NAME=php-7.2.20
PHP_TAR_PACKAGE_FILE_NAME=$PHP_FILE_NAME.tar.gz
WWW_USER_NAME=www-data
PHP_INSTALL_PREFIX=/usr/local/php

# install and deploy
if [[ $SOFTWARES_PATH != '' && -e $SOFTWARES_PATH ]]; then
    if !(id $WWW_USER_NAME &> /dev/null); then
        adduser --system --group --no-create-home --disabled-login --disabled-password $WWW_USER_NAME
    fi
    apt install -y libxml2-dev libssl-dev libcurl4-gnutls-dev libzip-dev libpng-dev libjpeg-dev libfreetype6-dev
    cd $SOFTWARES_PATH
    wget https://www.php.net/distributions/$PHP_TAR_PACKAGE_FILE_NAME
    tar zxf $PHP_TAR_PACKAGE_FILE_NAME
    cd $PHP_FILE_NAME
    ./configure \
        --prefix=$PHP_INSTALL_PREFIX \
        --bindir=/usr/local/bin \
        --sbindir=/usr/local/sbin \
        --enable-fpm \
        --with-fpm-user=$WWW_USER_NAME \
        --with-fpm-group=$WWW_USER_NAME \
        --with-config-file-scan-dir=$PHP_INSTALL_PREFIX/lib/php.d \
        --enable-mysqlnd \
        --with-mysqli=mysqlnd \
        --with-pdo-mysql=mysqlnd \
        --with-openssl \
        --with-curl \
        --enable-mbstring \
        --enable-zip \
        --with-gd \
        --with-png-dir \
        --with-jpeg-dir \
        --with-freetype-dir \
        --enable-pcntl
    make && make install
    cp ./sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm && chmod +x /etc/init.d/php-fpm
    update-rc.d php-fpm defaults
    mkdir -p $PHP_INSTALL_PREFIX/lib/php.d
    cp $PHP_INSTALL_PREFIX/etc/php-fpm.conf.default $PHP_INSTALL_PREFIX/etc/php-fpm.conf
    cp $PHP_INSTALL_PREFIX/etc/php-fpm.d/www.conf.default $PHP_INSTALL_PREFIX/etc/php-fpm.d/www.conf
    php-fpm
else
    echo 'ERROR: softwares path is not exist, STOP deploying PHP.'
fi
