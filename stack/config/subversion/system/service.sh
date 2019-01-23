#!/bin/bash

command=$1

function start() {
    echo -e "Starting Subversion server...";
    ${SUBVERSION_HOME}/bin/svn run
}

function stop() {
    echo -e "Stop experimental implementation ...";
    ${SUBVERSION_HOME}/bin/svn stop
}

function usage() {
    echo -e "$0 start|stop"
}

case ${command} in
    start) start ;;
    stop) stop ;;
    *) usage ;;
esac
