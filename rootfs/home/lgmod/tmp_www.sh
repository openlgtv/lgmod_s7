#!/bin/sh
# Source code released under GPL License
# tmp_www.sh script for Saturn6/Saturn7/BCM by xeros

echo "OpenLGTV: tmp_www.sh: copy /var/www to /tmp/www"
cp -r /var/www /tmp/

echo "OpenLGTV: tmp_www.sh: mount --bind /tmp/www /var/www"
mount --bind /tmp/www /var/www

echo "OpenLGTV: tmp_www.sh: /etc/init.d/httpd restart"
/etc/init.d/httpd restart
