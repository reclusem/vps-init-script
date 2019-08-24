#!/bin/bash

# install
apt install -y mysql-server
# run the secure script for MySQL
mysql_secure_installation
