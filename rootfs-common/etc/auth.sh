#!/bin/sh

HTTPD_CONF="/mnt/lg/user/lgmod/httpd.conf"
PASSWD=`awk -F: '/cgi-bin/ {print $3}' $HTTPD_CONF`
while [ "$pass" != "$PASSWD" ]; do
	echo -n "Password: "; read -s pass; echo
done
exec /bin/sh -l
