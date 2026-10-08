FROM debian:bookworm

# set debconf's default frontend mode to noninteractive
# to prevent spamming the build logs with the same debconf error
# debconf: unable to initialize frontend: Dialog
# debconf: (No usable dialog-like program is installed, so the dialog based frontend cannot be used. at /usr/share/perl5/Debconf/FrontEnd/Dialog.pm line 76, <> line 4.)
# debconf: falling back to frontend: Readline
ARG DEBIAN_FRONTEND=noninteractive

# install base requirements
RUN apt-get update -qq && apt-get -yqq install apt-transport-https
RUN apt-get -yqq install acl build-essential ca-certificates curl gconf-service git gnupg libc-client-dev libicu-dev libfontconfig \
    libfreetype6-dev libjpeg62-turbo-dev libkrb5-dev libmagickwand-dev libpng-dev libpng16-16 \
    lsb-release poppler-utils software-properties-common ssl-cert sudo unzip unixodbc unixodbc-dev vim wfrench wget zip zlib1g-dev

# add chrome/puppeteer dependencies
# see https://github.com/GoogleChrome/puppeteer/blob/master/docs/troubleshooting.md#running-puppeteer-in-docker
RUN apt-get -yqq install fonts-liberation libappindicator3-1 libasound2 libatk-bridge2.0-0 libatk1.0-0 libc6 libcairo2 libcups2 \
    libdbus-1-3 libexpat1 libfontconfig1 libgbm1 libgcc1 libglib2.0-0 \
    libgtk-3-0 libnspr4 libnss3 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 \
    libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 \
    libxrender1 libxss1 libxtst6

# create APT keyring directory
RUN mkdir -p /etc/apt/keyrings

# upgrade openssl
RUN apt-get install -yqq --upgrade openssl

# add php prepo
RUN curl -sSL https://packages.sury.org/php/apt.gpg | apt-key add -
RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list

# add msodbcsql repo
RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg
RUN curl -sSL "https://packages.microsoft.com/config/debian/$(lsb_release -sr)/prod.list" > /etc/apt/sources.list.d/mssql-release.list

# add yarn repo
RUN curl -sSL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list

# add node repo
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN printf "Types: deb\nURIs: https://deb.nodesource.com/node_26.x/\nSuites: nodistro\nComponents: main\nSigned-By: /etc/apt/keyrings/nodesource.gpg" > /etc/apt/sources.list.d/nodesource.sources

# install pie
RUN curl -sSL --output /usr/local/bin/pie https://github.com/php/pie/releases/latest/download/pie.phar
RUN sudo chmod +x /usr/local/bin/pie

# install php8.5
RUN apt-get -qq update && apt-get -yqq install --no-install-recommends \
    libgd3 \
    php8.5 \
    php8.5-fpm \
    php8.5-bcmath \
    php8.5-bz2 \
    php8.5-cli \
    php8.5-common \
    php8.5-curl \
    php8.5-dev \
    php8.5-gd \
    php8.5-gearman \
    php8.5-intl \
    php8.5-imagick \
    php8.5-imap \
    php8.5-mbstring \
    php8.5-mysql \
    php8.5-redis \
    php8.5-soap \
    php8.5-sqlite3 \
    php8.5-xml \
    php8.5-zip \
    php8.5-gmp \
    php8.5-xdebug

# set sensible php options
RUN echo "date.timezone = Europe/Paris" >> /etc/php/8.5/cli/php.ini && \
    echo "memory_limit = 512M" >> /etc/php/8.5/cli/php.ini && \
    echo "error_reporting = E_ALL" >> /etc/php/8.5/cli/php.ini

# install msodbcsql18
RUN ACCEPT_EULA=Y apt-get install -yqq msodbcsql18

# install sqlsrv and pdo_sqlsrv with pie
RUN pie install microsoft/sqlsrv
RUN pie install microsoft/pdo_sqlsrv

# disable Xdebug by default
RUN phpdismod xdebug

# install composer
RUN curl -sSL https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# install phpunit
RUN curl -sSL --output /usr/local/bin/phpunit https://phar.phpunit.de/phpunit-13.phar
RUN chmod +x /usr/local/bin/phpunit

# install node and yarn
RUN apt-get -yqq install nodejs yarn

# show installed packages info
# redirect stderr to /dev/null because composer will complain about running it as root
RUN echo "node: " && node --version && \
    echo "yarn: " && yarn --version && \
    echo "pie: " && pie --version && \
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
