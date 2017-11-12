FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive

# install lib
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
RUN apt-get install -y sudo unzip curl wget git supervisor

# install repo
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
RUN apt-get update
RUN apt-get install -y google-chrome-stable
RUN apt-get install -y nodejs

# install noto sans
RUN apt-get install -y fonts-noto
# RUN wget -q https://noto-website-2.storage.googleapis.com/pkgs/NotoSansCJKjp-hinted.zip
# RUN unzip NotoSansCJKjp-hinted.zip
# RUN mkdir -p /usr/share/fonts/opentype/noto
# RUN mv NotoSans* /usr/share/fonts/opentype/noto
# RUN fc-cache -f -v

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

# install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer

# nginx config
ADD ./wordpress.conf /etc/nginx/sites-available/wordpress.conf
RUN rm /etc/nginx/sites-enabled/default
RUN ln -s /etc/nginx/sites-available/wordpress.conf /etc/nginx/sites-enabled/wordpress.conf
RUN mkdir /var/www/wordpress
RUN chown -R www-data /var/www

# php-fpm
RUN mkdir /run/php
RUN chown www-data /run/php

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
    --admin_email="admin@example.com" && \
    wp plugin install wordpress-importer --activate && \
    curl https://raw.githubusercontent.com/jawordpressorg/theme-test-data-ja/master/wordpress-theme-test-date-ja.xml > /tmp/heme-unit-test-data.xml && \
    wp import /tmp/heme-unit-test-data.xml --authors=create

# update option
RUN sudo service mysql start && \
    wp rewrite structure "/archives/%post_id%" && \
    wp option update show_on_front page && \
    wp option update page_on_front 701  && \
    wp option update page_for_posts 703 && \
    wp option update posts_per_page 5

#supervisord
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD sudo /usr/bin/supervisord

EXPOSE 80