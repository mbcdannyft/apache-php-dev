FROM ubuntu:14.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y update && apt-get -y upgrade

RUN apt-get -y install apache2 libapache2-modsecurity libapache2-mod-evasive
RUN apt-get -y install php5 libapache2-mod-php5 php5-mcrypt php5-mysql php5-redis
RUN apt-get -y install php5-xdebug
RUN apt-get -y install wget

RUN echo 'deb http://pkg.cloudflare.com/ utopic main' > /etc/apt/sources.list.d/cloudflare-main.list
RUN wget -qO- https://pkg.cloudflare.com/pubkey.gpg | apt-key add -
RUN apt-get update
RUN apt-get -y install libapache2-mod-cloudflare

RUN apt-get clean

ENV ADMIN_EMAIL dt@mbc-design.dk
ENV SERVER_NAME example.com

COPY 01-security.ini /etc/php5/apache2/conf.d/
COPY security.conf /etc/apache2/conf-available/
COPY 000-default.conf /etc/apache2/sites-available/
 
RUN a2enmod rewrite
RUN a2enmod headers

ENV MYSQLI_DEFAULT_PORT null
ENV MYSQLI_DEFAULT_HOST null
ENV MYSQLI_DEFAULT_USER null
ENV MYSQLI_DEFAULT_PASSWORD null

RUN echo "mysqli.default_port = $MYSQLI_DEFAULT_PORT"     >  /etc/php5/apache2/conf.d/02-mysqli-defaults.ini
RUN echo "mysqli.default_host = $MYSQLI_DEFAULT_HOST"     >> /etc/php5/apache2/conf.d/02-mysqli-defaults.ini
RUN echo "mysqli.default_user = $MYSQLI_DEFAULT_USER"     >> /etc/php5/apache2/conf.d/02-mysqli-defaults.ini
RUN echo "mysqli.default_pw   = $MYSQLI_DEFAULT_PASSWORD" >> /etc/php5/apache2/conf.d/02-mysqli-defaults.ini

ENV REMOVE_RULES NONE

COPY setup.py /tmp/
CMD python3 /tmp/setup.py
CMD rm -f /tmp/setup.py

EXPOSE 80

VOLUME /var/www/html
VOLUME /tmp/profile

CMD ["/usr/sbin/apachectl", "-D", "FOREGROUND"]
