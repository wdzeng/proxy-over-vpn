#!/bin/sh

echo 'Start nginx forward proxy server.'

(
/usr/sbin/nginx -g 'daemon off;'
code=$?
echo 'Nginx forward proxy server exited.' >&2

if [[ $code -eq 0 ]]; then 
    exit 1
else
    exit $code
fi
) &
