#!/bin/bash

command=$1

function start() {
    echo -e "Starting Jenkins server...";
    # Use to start Jenkins on jdk 8
    # java -jar ${JENKINS_HOME}/bin/jenkins.war --httpPort=${JENKINS_PORT}
    java -DJENKINS_HOME=${JENKINS_HOME}/data -jar ${JENKINS_HOME}/bin/jenkins.war --httpPort=${JENKINS_PORT}
    # Use to start Jenkins on jdk 11
    # see: https://jenkins.io/blog/2018/12/14/java11-preview-availability/
    # java -p ${JENKINS_HOME}/bin/jaxb-api.jar:${JENKINS_HOME}/bin/javax.activation.jar \
    #     --add-modules ${JENKINS_HOME}/bin/java.xml.bind,${JENKINS_HOME}/bin/java.activation \
    #     -cp ${JENKINS_HOME}/bin/jaxb-core.jar:${JENKINS_HOME}/bin/jaxb-impl.jar \
    #     -jar ${JENKINS_HOME}/bin/jenkins.war \
    #     --enable-future-java --httpPort=${JENKINS_PORT} --prefix=/jenkins
}

function stop() {
    echo -e "Stop experimental implementation ...";
    curl http://localhost:${JENKINS_PORT}/exit
}

function usage() {
    echo -e "$0 start|stop"
}

case ${command} in
    start) start ;;
    stop) stop ;;
    *) usage ;;
esac
