#!/usr/bin/env bash

CMD="$1"
BRANCH=`git branch --show-current`

if [[ "$BRANCH" == "master" ]]; then
    BRANCH="php"
fi

CONTAINER_NAME="mesavolt/$BRANCH"

case "$1" in
	build )
		docker build --no-cache -t $CONTAINER_NAME .
		;;
	run )
		docker run -it $CONTAINER_NAME
		;;
	push )
		docker push $CONTAINER_NAME:latest
		;;
	* )
		echo "Docker commands helper for you lazy fucks"
		echo "Usage: ./docker.sh [build|run|push]"
		echo "The container name is infered from the branch name:"
		echo " - master => mesavolt/php"
		echo " - php7.1 => mesavolt/php7.1"
		echo " - php7.4 => mesavolt/php7.4"
		echo " - php8.2 => mesavolt/php8.2"
		;;
esac
