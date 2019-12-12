# docker-php-image

> A minimal modern php environment

Based on `debian:jessie`, adds a non-root user (mesavolt) and the following packages :

* php7.4 (from https://deb.sury.org) and some useful extensions (full list in [Dockerfile](./Dockerfile))
* composer
* phpunit
* node8 (LTS)
* yarn
* sudo
* vim

Use the `./docker [build|run|push]` helper to manage the image and the docker repository.
