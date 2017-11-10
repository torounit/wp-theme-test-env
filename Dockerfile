FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive

# install lib
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
RUN apt-get install -y sudo unzip curl wget git
#RUN apt install -y git build-essential jq curl libxml2-dev libssl-dev libsslcommon2-dev libcurl4-openssl-dev libbz2-dev libpng-dev libmysqlclient-dev libltdl-dev libtidy-dev libxslt-dev libicu-dev autoconf bison unzip

# install chrome
RUN echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
RUN apt-get update
RUN apt-get install -y google-chrome-stable

# install noto sans
RUN wget -q https://noto-website-2.storage.googleapis.com/pkgs/NotoSansCJKjp-hinted.zip
RUN unzip NotoSansCJKjp-hinted.zip
RUN mkdir /usr/share/fonts/NotoSansCJKjp
RUN mv NotoSans* /usr/share/fonts/NotoSansCJKjp/

# install php
RUN apt-get install -y php7.0 php7.0-cli php7.0-dev php7.0-mbstring php7.0-mcrypt php7.0-mysql php7.0-gd php7.0-curl php7.0-zip php-xdebug php-imagick php7.0-fpm

# install mysql
RUN echo "mysql-server mysql-server/root_password password root" | debconf-set-selections
RUN echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections
RUN apt-get install -y nginx mysql-server
RUN usermod -d /var/lib/mysql mysql

# install wp cli
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x wp-cli.phar
RUN mv wp-cli.phar /usr/local/bin/wp

# Nginx config
# RUN sed -i "s/user www-data/user ubuntu/" /etc/nginx/nginx.conf
# RUN sed -i "s/user = apache/user = ubuntu/" /etc/php-fpm.d/www.conf
# RUN sed -i "s/group = apache/group = ubuntu/" /etc/php-fpm.d/www.conf
ADD ./wordpress.conf /etc/nginx/sites-available/wordpress.conf
RUN rm /etc/nginx/sites-enabled/default
RUN ln -s /etc/nginx/sites-available/wordpress.conf /etc/nginx/sites-enabled/wordpress.conf
RUN mkdir /var/www/wordpress
RUN chown www-data /var/www/wordpress

# create user
RUN echo 'www-data ALL=(root) NOPASSWD: ALL' >> /etc/sudoers
USER www-data

# download wp
WORKDIR /var/www/wordpress
RUN curl -s https://wordpress.org/latest.tar.gz > /tmp/wordpress.tar.gz
RUN tar --strip-components=1 -zxmf /tmp/wordpress.tar.gz -C ./

# install wp
RUN sudo service mysql start && \
    sudo mysqladmin create "wordpress" --user="root" --password="root" && \
    wp config create --dbname=wordpress --dbuser=root --dbpass=root && \
    wp core install \
    --url=http://localhost \
    --title="WP on Docker" \
    --admin_user="admin" \
    --admin_password="admin" \
    --admin_email="admin@example.com"

#supervisord
RUN sudo apt-get install -y supervisor
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD sudo /usr/bin/supervisord

EXPOSE 80