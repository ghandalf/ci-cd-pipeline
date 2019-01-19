#!/bin/bash

command=$1

function start() {
    echo -e "Start is not implemented yet...";
}

function stop() {
    echo -e "Stop is not implemented yet...";
}

function usage() {
    echo -e "$0 start|stop"
}

case ${command} in
    start) start ;;
    stop) stop ;;
    *) usage ;;
esac