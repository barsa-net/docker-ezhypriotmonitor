FROM php:7.2-apache
RUN set -eux; apt update; apt install iputils-ping -y
COPY eHM/ /var/www/html/
