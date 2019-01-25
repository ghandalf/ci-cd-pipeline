#!/bin/bash

command=$1

function start() {
    echo -e "Starting Nexus server...";
    
    if [ -f ${NEXUS_DATA}/etc/nexus.properties ]; then
        sed -i "s/# application-port=8081/application-port=${NEXUS_PORT}/g" ${NEXUS_DATA}/etc/nexus.properties
    fi
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
