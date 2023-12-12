#!/bin/sh

# Configuration comes from https://github.com/microsoft/Oryx/blob/01392f90eeeb9dbeb9c78c14b0ef443ed274abb6/src/startupscriptgenerator/src/php/scriptgenerator.go

# Enter the source directory to make sure the script runs where the user expects
cd /home/site/wwwroot
export APACHE_PORT=8080

if [  -n "$PHP_ORIGIN" ] && [ "$PHP_ORIGIN" = "php-fpm" ]; then
   export NGINX_DOCUMENT_ROOT='/home/site/wwwroot'
   service nginx start
else
   export APACHE_DOCUMENT_ROOT='/home/site/wwwroot'
fi

apache2-foreground;