# docker-php-image

> A minimal modern php environment

Based on `debian:bullseye`, adds a non-root user (mesavolt) and the following packages :

* PHP 8.2 (from https://deb.sury.org) and some useful extensions (full list in [Dockerfile](./Dockerfile))
* composer
* phpunit
* Node 16 (LTS)
* yarn
* sudo
* vim

Use the `./docker [build|run|push]` helper to manage the image and the docker repository.
