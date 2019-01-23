FROM centos

LABEL Author="Francis Ouellet <fouellet@dminc.com>"
LABEL Description="Base on Centos 7"

ENV CONTAINER_NAME subversion
ENV CONTAINER_IMAGE ghandalf/subversion:${CONTAINERS_VERSION}
ENV CONTAINER_VERSION ${CONTAINERS_VERSION}
ENV APP_USER subversion
ENV APP_GROUP sgroup
ENV APP_HOME /usr/share/subversion
ENV SUBVERSION_PORT 32182

RUN yum -y update
RUN yum --security check-update
RUN yum --security update
RUN yum install -y tree netstat dnsutils wget mailx
RUN yum clean all

# Subversion installation
RUN mkdir -p ${APP_HOME} ${APP_HOME}/data/logs
RUN wget http://apache.mirror.globo.tech/subversion/subversion-1.11.1.tar.gz -P ${APP_HOME}
RUN tar xvf ${APP_HOME}/*.tar.gz -P ${APP_HOME}

COPY ./config/subversion/system/service.sh ${APP_HOME}/

RUN chmod 0750 ${APP_HOME}/service.sh

RUN groupadd -g 1002 ${APP_GROUP}
RUN useradd -r -u 1002 -M -b ${APP_HOME}} -g ${APP_GROUP} ${APP_USER}
RUN usermod -s /sbin/nologin ${APP_USER}
RUN chown -R ${APP_USER}:${APP_GROUP} ${APP_HOME}
# Subversion installation done

# System configuration
COPY ./config/nexus/system/profile.d/subversion.sh /etc/profile.d/
RUN chmod 0644 /etc/profile.d/subversion.sh
# System configuration done

EXPOSE ${SUBVERSION_PORT}

# The USER instruction sets the user name (or UID) and optionally 
# the user group (or GID) to use when running the image and for 
# any RUN, CMD and ENTRYPOINT instructions that follow it in the Dockerfile.
USER ${APP_USER}

# TODO: https://subversion.apache.org/download.cgi#verifying
ENTRYPOINT ["/usr/share/nexus/service.sh", "start"]
