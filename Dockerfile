FROM php:7.2.5-apache
MAINTAINER Jan Hajek <hajek.j@hotmail.com>

EXPOSE 8080

ENV PORT 8080

WORKDIR /var/www/html

ENTRYPOINT ["/bin/init_container.sh"]
