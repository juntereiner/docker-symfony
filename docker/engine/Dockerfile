FROM composer

FROM php:7.2-fpm-alpine

COPY --from=composer /usr/bin/composer /usr/local/bin/composer

RUN apk add --no-cache \
        ca-certificates \
        icu-libs \
        git \
        unzip \
        bash \
        zsh \
        make \
        libmemcached-libs \
        libmemcached-dev \
        autoconf \
        gcc \
        libc-dev \
        cyrus-sasl-dev \
        openssh-client \
        zlib-dev && \
    pecl install apcu && \
    echo "extension=apcu.so" >> /usr/local/etc/php/conf.d/apcu.ini && \
    apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        icu-dev && \
    docker-php-ext-install \
        intl \
        zip && \
    docker-php-ext-enable opcache && \
    docker-php-ext-install pdo_mysql && \
    apk del .build-deps && \
    apk add gosu --update --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted

RUN addgroup comics && \
    adduser -D -h /home/batman -s /bin/sh -G comics batman \
    && bash -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" \
    && sed -i -- 's/robbyrussell/wezm+/g' /root/.zshrc \
    && sed -i -- 's/git/git git-flow git-extras symfony2 command-not-found composer/g' ~/.zshrc \
    && cp ~/.zshrc /home/batman/.zshrc \
    && cp -R ~/.oh-my-zsh /home/batman/.oh-my-zsh \
    && sed -i -- 's/\/root/\/home\/batman/g' /home/batman/.zshrc \
    && chown -R batman /home/batman \
    && chgrp -R comics /home/batman \
    && echo 'export PATH=$HOME/bin:/usr/local/bin:/usr/local/sbin:$HOME/.composer/vendor/bin:$PATH' >> /home/batman/.zshrc

COPY entrypoint.sh /entrypoint

ENTRYPOINT ["/entrypoint"]
