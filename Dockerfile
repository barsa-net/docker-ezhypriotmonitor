FROM --platform=linux/armhf php:7.2-apache
RUN set -eux; apt update; apt install iputils-ping -y
COPY ePM/ /var/www/html/
