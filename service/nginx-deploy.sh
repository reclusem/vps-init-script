#!/bin/bash

NGINX_FILE_NAME=nginx-1.18.0
NGINX_TAR_PACKAGE_FILE_NAME=$NGINX_FILE_NAME.tar.gz
NGINX_INSTALL_PREFIX=/usr/local/nginx

# install and deploy
if [[ $SOFTWARES_PATH != '' && -e $SOFTWARES_PATH ]]; then
    add_www_user
    apt install -y libpcre3-dev zlib1g-dev openssl libssl-dev
    cd $SOFTWARES_PATH
    wget http://nginx.org/download/$NGINX_TAR_PACKAGE_FILE_NAME
    tar zxf $NGINX_TAR_PACKAGE_FILE_NAME
    cd $NGINX_FILE_NAME
    ./configure \
        --prefix=$NGINX_INSTALL_PREFIX \
        --user=www-data \
        --group=www-data \
        --sbin-path=/usr/local/sbin/nginx \
        --with-http_gzip_static_module \
        --with-http_ssl_module
    make && make install
    cp $WORK_PATH/config/nginx /etc/init.d/ && chmod +x /etc/init.d/nginx
    update-rc.d nginx defaults
    service nginx start
else
    echo 'ERROR: softwares path is not exist, STOP deploying Nginx.'
fi
