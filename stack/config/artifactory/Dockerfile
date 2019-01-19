FROM centos

LABEL Author="Francis Ouellet <fouellet@dminc.com>"
LABEL Description="Base on Centos 7"

ENV CONTAINER_NAME ${NAMES[1]}
ENV CONTAINER_IMAGE ${IMAGES[1]}
ENV CONTAINER_VERSION ${CONTAINERS_VERSION}
ENV APP_USER ${USERS[1]}
ENV APP_GROUP ${GROUPS[1]}
ENV APP_HOME ${PATHS[1]}

RUN yum -y update
RUN yum --security check-update
RUN yum --security update
# For security reason, jre will have to be installed instead of jdk
RUN yum search artifactoy
# RUN yum install -y tree netstat dnsutils java-1.8.0-openjdk
RUN groupadd -g 1002 ${APP_GROUP}
RUN useradd -r -u 1002 -m -b /usr/share -g ${APP_GROUP} ${APP_USER}
RUN mkdir -p ${APP_HOME}/data/logs
RUN chown -R ${APP_USER}:${APP_GROUP} ${APP_HOME}
RUN chmod 755 ${APP_HOME}/service.sh

EXPOSE ${PORTS[1]}

# Expect to have service.sh under rc.local or systemD, 
# so that starting the container will start the application
# ENTRYPOINT ["service.sh", "start"]

USER ${APP_USER}
