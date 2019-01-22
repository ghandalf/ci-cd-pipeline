FROM centos

LABEL Author="Francis Ouellet <fouellet@dminc.com>"
LABEL Description="Base on Centos 7"

ENV CONTAINER_NAME gitlab
ENV CONTAINER_IMAGE ghandalf/gitlab:${CONTAINERS_VERSION}
ENV CONTAINER_VERSION ${CONTAINERS_VERSION}
ENV APP_USER gituser
ENV APP_GROUP gitgroup
ENV APP_HOME /usr/share/gitlab
ENV JENKINS_PORT 32182

RUN yum -y update
RUN yum --security check-update
RUN yum --security update
RUN yum install -y tree netstat dnsutils wget mailx

RUN groupadd -g 1002 ${APP_GROUP}
RUN useradd -r -u 1002 -m -b /usr/share -g ${APP_GROUP} ${APP_USER}
RUN mkdir -p ${APP_HOME}/data/logs
RUN chown -R ${APP_USER}:${APP_GROUP} ${APP_HOME}

EXPOSE ${JENKINS_PORT}

# Expect to have service.sh under rc.local or systemD, 
# so that starting the container will start the application
# ENTRYPOINT ["service.sh", "start"]

USER ${APP_USER}
