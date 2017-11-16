#!/usr/bin/env bash

set -ex

# Install WordPress.
sudo service mysql start
wp config create --dbname=wordpress --dbuser=root --dbpass=root
wp core install \
    --url=http://localhost \
    --title="WP Theme Test Environment" \
    --admin_user="admin" \
    --admin_password="admin" \
    --admin_email="admin@example.com"
wp plugin install wordpress-importer --activate

# Import Theme Unit Test.
curl https://raw.githubusercontent.com/jawordpressorg/theme-test-data-ja/master/wordpress-theme-test-date-ja.xml > /tmp/wordpress-theme-test-date-ja.xml
wp import /tmp/wordpress-theme-test-date-ja.xml --authors=create

# Import Theme Unit Test ja.
curl https://raw.githubusercontent.com/jawordpressorg/theme-test-data-ja/master/wordpress-theme-test-date-ja.xml > /tmp/wordpress-theme-test-date-ja.xml
wp import /tmp/wordpress-theme-test-date-ja.xml --authors=create

# Update options.
wp rewrite structure "/%postname%/"
wp option update posts_per_page 5
wp option update page_comments 1
wp option update comments_per_page 5
wp option update show_on_front page
wp option update page_on_front 701
wp option update page_for_posts 703