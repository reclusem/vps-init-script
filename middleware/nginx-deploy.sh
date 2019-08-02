#!/bin/bash

NGINX_FILE_NAME=nginx-1.17.1
NGINX_TAR_PACKAGE_FILE_NAME=$NGINX_FILE_NAME.tar.gz
WWW_USER_NAME=www-data
NGINX_INSTALL_PREFIX=/usr/local/nginx

# install and deploy
if [[ $SOFTWARES_PATH != '' && -e $SOFTWARES_PATH ]]; then
    if !(id $WWW_USER_NAME &> /dev/null); then
        adduser --system --group --no-create-home --disabled-login --disabled-password $WWW_USER_NAME
    fi
    apt install -y libpcre3-dev zlib1g-dev openssl libssl-dev
    cd $SOFTWARES_PATH
    wget http://nginx.org/download/$NGINX_TAR_PACKAGE_FILE_NAME
    tar zxf $NGINX_TAR_PACKAGE_FILE_NAME
    cd $NGINX_FILE_NAME
    ./configure \
        --prefix=$NGINX_INSTALL_PREFIX \
        --user=www-data \
        --group=www-data \
        --sbin-path=/usr/sbin/nginx \
        --with-http_gzip_static_module \
        --with-http_ssl_module
    make && make install
    cp $WORK_PATH/config/nginx /etc/init.d/ && chmod +x /etc/init.d/nginx
    update-rc.d nginx defaults
    nginx
else
    echo 'ERROR: softwares path is not exist, STOP deploying Nginx.'
fi
