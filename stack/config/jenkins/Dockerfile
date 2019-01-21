FROM centos

LABEL Author="Francis Ouellet <fouellet@dminc.com>"
LABEL Description="Base on Centos 7"

ENV CONTAINER_NAME jenkins
ENV CONTAINER_IMAGE ghandalf/jenkins:${CONTAINERS_VERSION}
ENV CONTAINER_VERSION ${CONTAINERS_VERSION}
ENV APP_USER jenkinsuser
ENV APP_GROUP jenkinsgroup
ENV APP_HOME /usr/share/jenkins
ENV JAVA_INSTALL /usr/share/java

# RUN yum -y update
# RUN yum --security check-update
# RUN yum --security update
# RUN yum install -y tree netstat dnsutils wget 

# Java installation first
RUN mkdir -p ${JAVA_INSTALL}
# RUN wget --no-cookies --no-check-certificate \
# --header "Cookie: oraclelicense=accept-securebackup-cookie" \
# http://download.oracle.com/otn-pub/java/jdk/11.0.2+9/f51449fcd52f4d52b93a989c5c56ed3c/jdk-11.0.2_linux-x64_bin.tar.gz
COPY ./config/jdk/jdk-11*.tar.gz ${JAVA_INSTALL}/
RUN tar xzf ${JAVA_INSTALL}/jdk-11*.tar.gz -C ${JAVA_INSTALL}/
RUN ls -la  ${JAVA_INSTALL}/
# Configure alternatives to use jdk-11 
RUN alternatives --install /usr/bin/java java ${JAVA_INSTALL}/jdk-11.0.2/bin/java 2
RUN echo 1 | alternatives --config java
RUN alternatives --install /usr/bin/jar jar ${JAVA_INSTALL}/jdk-11.0.2/bin/jar 2
RUN alternatives --install /usr/bin/javac javac ${JAVA_INSTALL}/jdk-11.0.2/bin/javac 2
RUN alternatives --set jar ${JAVA_INSTALL}/jdk-11.0.2/bin/jar
RUN alternatives --set javac ${JAVA_INSTALL}/jdk-11.0.2/bin/javac
RUN java -version
# Java installation done


COPY ./config/jenkins/system/service.sh ${APP_HOME}/

RUN ls -la /etc/profile.d/java.sh
RUN cat /etc/environment
#RUN echo "export JAVA_HOME=${JAVA_INSTALL}/jdk-11.0.2" >> /etc/environment
RUN sed 'i\export JAVA_HOME=\/usr\/share\/java\/jdk-11.0.2' /etc/environment
RUN cat /etc/environment
#RUN echo "export PATH=$PATH:${JAVA_HOME}/bin" 
RUN sed 's/\<PATH=\>/& ${JAVA_HOME}\/bin:/' /etc/environment 
RUN cat /etc/environment

# RUN wget --no-cookies --no-check-certificate \
# --header "Cookie: oraclelicense=accept-securebackup-cookie" \
# https://download.oracle.com/otn-pub/java/jdk/8u202-b08/1961070e4c9b4e26a04e7f5a083f551e/jdk-8u202-linux-x64.tar.gz
# RUN tar xzf jdk-8*.tar.gz -C /usr/share/java
# RUN cd /usr/share/java/jdk1.8.0_202
# RUN alternatives --install /usr/bin/java java /usr/share/java/jdk-11.0.2/bin/java 2
# RUN alternatives --config java


RUN groupadd -g 1002 ${APP_GROUP}
RUN useradd -r -u 1002 -m -b /usr/share -g ${APP_GROUP} ${APP_USER}
RUN mkdir -p ${APP_HOME}/data/logs
RUN chown -R ${APP_USER}:${APP_GROUP} ${APP_HOME}

EXPOSE 32183

# Expect to have service.sh under rc.local or systemD, 
# so that starting the container will start the application
# ENTRYPOINT ["service.sh", "start"]

USER ${APP_USER}
