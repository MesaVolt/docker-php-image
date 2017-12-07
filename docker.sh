#!/usr/bin/env bash

CMD="$1"
CONTAINER_NAME=mesavolt/php7.1

case "$1" in
	build )
		docker build -t $CONTAINER_NAME .
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
		;;
esac