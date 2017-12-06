FROM debian:jessie

# install base requirements
RUN apt-get update && apt-get install -y \
     git zip unzip apt-utils apt-transport-https software-properties-common \
     zlib1g-dev libfreetype6-dev libpng12-dev libjpeg62-turbo-dev \
     libfontconfig curl wget build-essential ca-certificates ssl-cert lsb-release

# add php7 repo
# RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php -y
# RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/pkg-gearman -y

RUN curl -sS https://packages.sury.org/php/apt.gpg | apt-key add -
RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list

# add yarn repo
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# add node repo
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -

# update apt cache
RUN apt-get update

# install php7.1
RUN apt-get install --no-install-recommends -y \
    php7.1 php7.1-common php7.1-cli php7.1-opcache php7.1-readline \ 
    php7.1-bz2 php7.1-curl php7.1-gd php7.1-intl php7.1-json php7.1-mysql \ 
    php7.1-xml php7.1-zip php-xdebug

# install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# install phpunit
RUN curl --location --output /usr/local/bin/phpunit https://phar.phpunit.de/phpunit.phar
RUN chmod +x /usr/local/bin/phpunit

# install node and yarn
RUN apt-get install -y nodejs yarn

# CMD ["php", "-a"]
