FROM php:7.2.5-apache
MAINTAINER Jan Hajek <hajek.j@hotmail.com>

WORKDIR /var/www/html

ENTRYPOINT ["/bin/init_container.sh"]
