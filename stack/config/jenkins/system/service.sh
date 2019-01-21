#!/bin/bash

command=$1

function start() {
    echo -e "Starting Jenkins server...";
    java -jar ${JENKINS_HOME}/jenkins.war --httpPort=32183

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
