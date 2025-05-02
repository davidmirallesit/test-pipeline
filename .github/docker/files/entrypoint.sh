#!/bin/bash
chown www-data. -R /var/www/webpremium/cache
service redis-server start &
sleep 5
cd / && cat redis-commands.txt | redis-cli -a foobared -n 6
service php8.2-fpm start &
nginx -g "daemon off;"