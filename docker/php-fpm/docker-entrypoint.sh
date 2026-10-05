#!/bin/sh
set -e

cd /var/www

if [ -f composer.json ] && [ ! -f vendor/autoload.php ]; then
    composer install --no-interaction --prefer-dist
fi

exec docker-php-entrypoint "$@"
