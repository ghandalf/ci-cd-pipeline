#!/bin/bash

command=$1

function start() {
    echo -e "Starting Nexus server...";
    # Use to start Nexus on jdk 8
    ${NEXUS_HOME}/bin/nexus run
}

function stop() {
    echo -e "Stop experimental implementation ...";
    ${NEXUS_HOME}/bin/nexus stop
}

function usage() {
    echo -e "$0 start|stop"
}

case ${command} in
    start) start ;;
    stop) stop ;;
    *) usage ;;
esac
