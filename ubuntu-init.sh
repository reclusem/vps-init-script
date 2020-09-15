#!/bin/bash

# Ubuntu Version: 18.04

export SOFTWARES_PATH=/data/softwares
export WORK_PATH=`pwd`
export WWW_USER_NAME=www-data

#
# FUNCTION
#

# Usage: service_deploy [param1] [param2]
# [param1] service name label
# [param2] service deploy script file name
service_deploy()
{
    read -t 60 -n9 -p "Would you want to deploy ${1}?(y/n) " result_for_choosing
    if [[ $result_for_choosing =~ y|Y ]]; then
        DEPLOY_SCRIPT_FILE_NAME=$WORK_PATH/service/${2}.sh
        chmod +x $DEPLOY_SCRIPT_FILE_NAME && $DEPLOY_SCRIPT_FILE_NAME
    fi
}

# add new user named www
add_www_user()
{
    if !(id $WWW_USER_NAME &> /dev/null); then
        adduser --system --group --no-create-home --disabled-login --disabled-password $WWW_USER_NAME
    fi
}
export -f add_www_user

#
# BASIC
#

# change apt sources to Aliyun-Source
read -t 60 -n9 -p "Would you want to change the apt sources to Aliyun-Source?(y/n) " result_for_choosing
if [[ $result_for_choosing =~ y|Y && `cat /etc/apt/sources.list | grep aliyun` = '' ]]; then
    cp /etc/apt/sources.list /etc/apt/sources.list.bak
    cp $WORK_PATH/config/sources.list /etc/apt/
fi

# update software source
apt update

# upgrade local softwares
read -t 60 -n9 -p "Would you want to upgrade local softwares?(y/n) " result_for_choosing
if [[ $result_for_choosing =~ y|Y ]]; then
    apt upgrade -y
fi

# install Chinese language environment
apt install -y language-pack-zh-hans

# modify system timezone
if [[ ! `timedatectl | grep "Time zone"` =~ 'Asia/Shanghai' ]]; then
    timedatectl set-timezone Asia/Shanghai
fi

# check BBR and enabled it
result_for_bbr_in_kernel=`sysctl net.ipv4.tcp_available_congestion_control | grep bbr`
result_for_bbr_in_mod=`lsmod | grep bbr`
if [[ "$result_for_bbr_in_kernel" = '' ]]; then
    echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
fi
if [[ "$result_for_bbr_in_mod" = '' ]]; then
    sysctl -p
fi

# install base software
apt install -y git vim tmux wget htop

# install some tools for compiling and installing from source code
apt install -y build-essential libtool autoconf

# create base dir
mkdir -p $SOFTWARES_PATH

#
# OPTIONAL
#

# deploy Nginx
service_deploy Nginx nginx-deploy

# deploy PHP
service_deploy PHP php-deploy

# deploy MySQL
service_deploy MySQL mysql-deploy

# deploy Redis
service_deploy Redis redis-deploy

# deploy shadowsocks-libev
service_deploy shadowsocks-libev shadowsocks-libev-debian
