# WP Theme Test Environment

Docker Image for WordPress Theme Test and Development.

## Usage

```bash
$ cd path/to/your-theme

# run docker and mount your theme.
$ docker run --name theme-test \
    -u www-data \
    -v `pwd`:/var/www/wordpress/wp-content/themes/your-theme \
    -p 80:80 \
    -d torounit/wp-theme-test-env

# activate your theme
$ docker exec theme-test  \
    bash -c 'wp theme activate your-theme --path=/var/www/wordpress'

# open browser.
$ open http://localhost
```

### WordPress account.

* username: `admin`
* password: `admin`

### Repo

[torounit/wp-theme-test-env](https://github.com/torounit/wp-theme-test-env)

### Example

* [torounit/vanilla](https://github.com/torounit/vanilla)
* [CircleCI](https://circleci.com/gh/torounit/vanilla)

### License

* GPL 2.0 or Later