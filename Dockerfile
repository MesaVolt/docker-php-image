FROM debian:stretch

# set debconf's default frontend mode to noninteractive
# to prevent spamming the build logs with the same debconf error
# debconf: unable to initialize frontend: Dialog
# debconf: (No usable dialog-like program is installed, so the dialog based frontend cannot be used. at /usr/share/perl5/Debconf/FrontEnd/Dialog.pm line 76, <> line 4.)
# debconf: falling back to frontend: Readline
ARG DEBIAN_FRONTEND=noninteractive

# install base requirements
RUN apt-get -qq update && apt-get -yqq install apt-utils apt-transport-https
RUN apt-get -yqq install acl build-essential ca-certificates curl gconf-service git libc-client-dev libicu-dev libfontconfig \
    libfreetype6-dev libjpeg62-turbo-dev libkrb5-dev libmagickwand-dev libpng-dev libpng16-16 \
    lsb-release poppler-utils software-properties-common ssl-cert sudo unzip vim wfrench wget zip zlib1g-dev

# add chrome/puppeteer dependencies
# see https://github.com/GoogleChrome/puppeteer/blob/master/docs/troubleshooting.md#running-puppeteer-in-docker
RUN apt-get -yqq install fonts-liberation libappindicator3-1 libasound2 libatk-bridge2.0-0 libatk1.0-0 libc6 libcairo2 libcups2 \
    libdbus-1-3 libexpat1 libfontconfig1 libgbm1 libgcc1 libglib2.0-0 \
    libgtk-3-0 libnspr4 libnss3 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 \
    libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 \
    libxrender1 libxss1 libxtst6

# add php7 repo
RUN curl -sS https://packages.sury.org/php/apt.gpg | apt-key add -
RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list

# add yarn repo
RUN curl -sSL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list

# add node repo
RUN curl -sSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
RUN echo "deb https://deb.nodesource.com/node_12.x $(lsb_release -sc) main" > /etc/apt/sources.list.d/nodesource.list
RUN echo "deb-src https://deb.nodesource.com/node_12.x $(lsb_release -sc) main" >> /etc/apt/sources.list.d/nodesource.list

# install php7.4
RUN apt-get -qq update && apt-get -yqq install --no-install-recommends \
    libgd3 \
    php7.4 \
    php7.4-fpm \
    php7.4-bcmath \
    php7.4-bz2 \
    php7.4-cli \
    php7.4-common \
    php7.4-curl \
    php7.4-exif \
    php7.4-gd \
    php7.4-gearman \
    php7.4-intl \
    php7.4-imagick \
    php7.4-imap \
    php7.4-json \
    php7.4-mbstring \
    php7.4-mysql \
    php7.4-opcache \
    php7.4-readline \
    php7.4-redis \
    php7.4-soap \
    php7.4-sqlite3 \
    php7.4-xml \
    php7.4-zip \
    php7.4-gmp \
    php7.4-xdebug

# set sensible php options
RUN echo "date.timezone = Europe/Paris" >> /etc/php/7.4/cli/php.ini && \
    echo "memory_limit = 512M" >> /etc/php/7.4/cli/php.ini && \
    echo "error_reporting = E_ALL" >> /etc/php/7.4/cli/php.ini

# install composer
RUN curl -sSL https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# install phpunit
RUN curl -sSL --output /usr/local/bin/phpunit https://phar.phpunit.de/phpunit-7.phar
RUN chmod +x /usr/local/bin/phpunit

# install node and yarn
RUN apt-get -yqq install nodejs yarn

# show installed packages info
# redirect stderr to /dev/null because composer will complain about running it as root
RUN echo "node: " && node --version && \
    echo "yarn: " && yarn --version && \
    echo "php: " && php --version && \
    echo "php modules: " && php -m && \
    echo "phpunit: " && phpunit --version && \
    echo "composer: " && composer --version 2> /dev/null

# add mesavolt user
RUN adduser --disabled-password --gecos "" mesavolt

# enable user mesavolt to run sudo with no password
RUN echo "mesavolt   ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/mesavolt && \
    chmod 0440 /etc/sudoers.d/mesavolt && visudo -c
RUN service sudo restart

# switch to mesavolt user (some tools complain when ran as root)
USER mesavolt
WORKDIR /home/mesavolt
