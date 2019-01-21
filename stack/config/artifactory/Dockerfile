FROM centos

LABEL Author="Francis Ouellet <fouellet@dminc.com>"
LABEL Description="Base on Centos 7"

ENV CONTAINER_NAME artifactory
ENV CONTAINER_IMAGE ghandalf/artifactory:${CONTAINERS_VERSION}
ENV CONTAINER_VERSION ${CONTAINERS_VERSION}
ENV APP_USER artifactoryuser
ENV APP_GROUP artifactorygroup
ENV APP_HOME /usr/share/artifactory

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

EXPOSE 32181

# Expect to have service.sh under rc.local or systemD, 
# so that starting the container will start the application
# ENTRYPOINT ["service.sh", "start"]

USER ${APP_USER}
