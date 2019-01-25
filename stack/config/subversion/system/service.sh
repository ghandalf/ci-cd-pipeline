#!/bin/bash

command=$1

function start() {
    echo -e "Starting Subversion server...";
    if [ -f ${SUBVERSION_HOME}/bin/svn ]; then
        ${SUBVERSION_HOME}/bin/svn run
    else
        echo -e "Welcome";
    fi
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
