FROM debian:jessie

# install base requirements
RUN apt-get update -qq && apt-get install -yqq \
     git zip unzip apt-utils apt-transport-https software-properties-common \
     zlib1g-dev libfreetype6-dev libpng12-dev libjpeg62-turbo-dev \
     libfontconfig curl wget build-essential ca-certificates ssl-cert lsb-release

# add php7 repo
RUN curl -sS https://packages.sury.org/php/apt.gpg | apt-key add -
RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list

# add yarn repo
RUN curl -sSL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# add node repo
RUN curl -sSL https://deb.nodesource.com/setup_8.x | bash -

# install php7.1
RUN apt-get update -qq && apt-get install --no-install-recommends -y \
    php7.1 php7.1-fpm php7.1-bz2 php7.1-cli php7.1-common php7.1-curl php7.1-gd \
    php7.1-intl php7.1-json php7.1-mbstring php7.1-mysql php7.1-opcache php7.1-readline \
    php7.1-sqlite3 php7.1-xml php7.1-zip php-gearman php-redis php-xdebug

RUN echo "date.timezone = Europe/Paris" >> /etc/php/7.1/cli/php.ini && \
    echo "memory_limit = 512M" >> /etc/php/7.1/cli/php.ini && \
    echo "error_reporting = E_ALL" >> /etc/php/7.1/cli/php.ini

# install composer
RUN curl -sSL https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# install phpunit
RUN curl -sSL --output /usr/local/bin/phpunit https://phar.phpunit.de/phpunit.phar
RUN chmod +x /usr/local/bin/phpunit

# install node and yarn
RUN apt-get install -y nodejs yarn

# show installed packages info
# redirect stderr to /dev/null because composer will complain about running it as root
RUN echo "node: " && node --version && \
    echo "yarn: " && yarn --version && \
    echo "php: " && php --version && \
    echo "php modules: " && php -m && \
    echo "phpunit: " && phpunit --version && \
    echo "composer: " && composer --version 2> /dev/null

# CMD ["php", "-a"]
