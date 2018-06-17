#!/bin/sh

uid=$(stat -c %u /srv)
gid=$(stat -c %g /srv)

if [ "$uid" = "0" ] && [ "$gid" = "0" ]; then
    if [ "$#" = "0" ]; then
        php-fpm --allow-to-run-as-root
    else
        exec "$@"
    fi
fi

sed -i -r "s/batman:x:\d+:\d+:/batman:x:$uid:$gid:/g" /etc/passwd
sed -i -r "s/comics:x:\d+:/comics:x:$gid:/g" /etc/group

sed -i "s/user = www-data/user = batman/g" /usr/local/etc/php-fpm.d/www.conf
sed -i "s/group = www-data/group = comics/g" /usr/local/etc/php-fpm.d/www.conf

chown -R $uid /home/batman
chgrp -R $gid /home/batman

if [ "$#" = "0" ]; then
    php-fpm
else
    exec gosu batman "$@"
fi
