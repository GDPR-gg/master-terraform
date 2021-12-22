#!/usr/bin/env bash
# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
set -o errexit
set -o nounset
set -x
OS=$(cat /etc/*release | grep "^ID=" | cut -f2- -d= | tr -d '"')
VERSION=$(cat /etc/*release | grep "^VERSION_ID=" | cut -f2- -d= | tr -d '"')

install_memcached() {
    if [ "$OS" = "centos" ] ;then
        yum -y update
        yum install -y libevent libevent-devel
        yum install -y \
        memcached \
        libmemcached
        yum install -y php php-pecl-memcache
        yum install -y httpd
        elif [ "$OS" = "debian" ] ;then
        apt-get update
        apt-get -y install memcached netcat
        apt-get -y install apache2
    else
        echo $OS
        echo $VERSION
    fi
    
}

create_log_dir()
{
    mkdir -p  /data1/applogs/memcached/
}

configure_memcache() {
    if [ "$OS" = "centos" ] ;then
    cat <<EOF > /etc/sysconfig/memcached
PORT="11211"
USER="memcached"
MAXCONN="1024"
CACHESIZE="2048"
OPTIONS="-t 4 -v >> /data1/applogs/memcached/memcached.log 2>&1"
EOF
        elif [ "$OS" = "debian" ] ;then
cat <<EOF > /etc/memcached.conf
# memcached default config file
# 2003 - Jay Bonci <jaybonci@debian.org>
# This configuration file is read by the start-memcached script provided as
# part of the Debian GNU/Linux distribution.
# Run memcached as a daemon. This command is implied, and is not needed for the
# daemon to run. See the README.Debian that comes with this package for more
# information.
-d
# Log memcached's output to /var/log/memcached
logfile /var/log/memcached.log
# Be verbose
# -v
# Be even more verbose (print client commands as well)
# -vv
# Start with a cap of 64 megs of memory. It's reasonable, and the daemon default
# Note that the daemon will grow to this size, but does not start out holding this much
# memory
-m 64
# Default connection port is 11211
-p 11211
# Run the daemon as root. The start-memcached will default to running as root if no
# -u command is present in this config file
-u memcache
# Specify which IP address to listen on. The default is to listen on all IP addresses
# This parameter is one of the only security measures that memcached has, so make sure
# it's listening on a firewalled interface.
-l 127.0.0.1
# Limit the number of simultaneous incoming connections. The daemon default is 1024
# -c 1024
# Lock down all paged memory. Consult with the README and homepage before you do this
# -k
# Return error when memory is exhausted (rather than removing items)
# -M
# Maximize core file limit
# -r
EOF
    else
        echo $OS
        echo $VERSION
    fi
}

test_php(){
    cat <<EOF > /var/www/html/info.php
<?php
phpinfo();
?>
EOF
}

## Service memcached start
memcached_start() {
    service memcached restart
}

## Service apache start
httpd_start(){
    if [ "$OS" = "centos" ] ;then
        service httpd restart
        elif [ "$OS" = "debian" ] ;then
        systemctl restart apache2
    else
        echo $OS
        echo $VERSION
    fi
}

#main
install_memcached
create_log_dir
configure_memcache
memcached_start
test_php
httpd_start