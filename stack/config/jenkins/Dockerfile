FROM centos

LABEL Author="Francis Ouellet <fouellet@dminc.com>"
LABEL Description="Base on Centos 7"

ENV CONTAINER_NAME jenkins
ENV CONTAINER_IMAGE ghandalf/jenkins:${CONTAINERS_VERSION}
ENV CONTAINER_VERSION ${CONTAINERS_VERSION}
ENV APP_USER jenkins
ENV APP_GROUP jgroup
ENV APP_HOME /usr/share/jenkins
ENV JENKINS_HOME ${APP_HOME}
ENV JENKINS_PORT 32183
# JDK jdk1.8.0_202 is the default and jdk-11.0.2 used by Jenkins jobs
ENV JAVA_VERSION jdk1.8.0_202
ENV JAVA_DIR /usr/share/java
# Maven 3.6.0 used by Jenkins jobs
ENV MAVEN_VERSION apache-maven-3.6.0
ENV MAVEN_DIR /usr/share/maven
# Ant used by Jenkins jobs
ENV ANT_VERSION apache-ant-1.10.5
ENV ANT_DIR /usr/share/ant
# Node v10.15.0 used by Jenkins jobs
ENV NODEJS_DIR /usr/share/nodejs
ENV NODEJS_VERSION node-v10.15.0-linux-x64
# SonarQube
ENV SONARQUBE_HOME /usr/share/sonarqube
ENV SONARQUBE_VERSION sonarqube-7.5
# SonarQube Scanner
# to be installed as a plugin his name: SonarQube Scanner for Jenkins
# Nexus IQ server, 
# to be installed as a plugin his name: Nexus Platform
# Maven Integration plugin must be installed

RUN yum -y update
RUN yum --security check-update
RUN yum --security update
RUN yum install -y tree net-tools bind-utils wget mailx unzip

# Subversion 1.8 installation with RPM
COPY ./config/jenkins/system/yum.repos.d/Wandisco-svn.repo /etc/yum.repos.d/
RUN chmod 0644 /etc/yum.repos.d/Wandisco-svn.repo
RUN yum clean all
RUN yum install -y subversion
RUN svn --version
# Subversion 1.8 installation done

# Git 2.18 installation with RPM
COPY ./config/jenkins/system/yum.repos.d/Wandisco-git.repo /etc/yum.repos.d/
RUN chmod 0644 /etc/yum.repos.d/Wandisco-git.repo
RUN yum clean all
RUN yum install -y git
RUN git --version
# Git 2.18 installation done

# Java installation
RUN mkdir -p ${JAVA_DIR}
#    JDK 8
RUN wget --no-cookies --no-check-certificate \
    --header "Cookie: oraclelicense=accept-securebackup-cookie" \
    https://download.oracle.com/otn-pub/java/jdk/8u202-b08/1961070e4c9b4e26a04e7f5a083f551e/jdk-8u202-linux-x64.tar.gz \
    -P ${JAVA_DIR}
RUN tar xzf ${JAVA_DIR}/jdk-8*.tar.gz -C ${JAVA_DIR}/
# Configure alternatives to use installed JDK
RUN alternatives --install /usr/bin/java java ${JAVA_DIR}/${JAVA_VERSION}/bin/java 2
RUN echo 1 | alternatives --config java
RUN alternatives --install /usr/bin/jar jar ${JAVA_DIR}/${JAVA_VERSION}/bin/jar 2
RUN alternatives --install /usr/bin/javac javac ${JAVA_DIR}/${JAVA_VERSION}/bin/javac 2
RUN alternatives --set jar ${JAVA_DIR}/${JAVA_VERSION}/bin/jar
RUN alternatives --set javac ${JAVA_DIR}/${JAVA_VERSION}/bin/javac
RUN java -version
#    JDK 8 done
#    JDK 11
RUN wget --no-cookies --no-check-certificate \
    --header "Cookie: oraclelicense=accept-securebackup-cookie" \
    http://download.oracle.com/otn-pub/java/jdk/11.0.2+9/f51449fcd52f4d52b93a989c5c56ed3c/jdk-11.0.2_linux-x64_bin.tar.gz \
    -P ${JAVA_DIR}
RUN tar xzf ${JAVA_DIR}/jdk-11*.tar.gz -C ${JAVA_DIR}/
RUN ls -la  ${JAVA_DIR}/
#    JDK 11 done
# Java installation done

# Maven installation
RUN mkdir -p ${MAVEN_DIR}
RUN wget http://apache.mirror.iweb.ca/maven/maven-3/3.6.0/binaries/apache-maven-3.6.0-bin.tar.gz \
    -P ${MAVEN_DIR}
RUN tar xvf ${MAVEN_DIR}/apache*.tar.gz -C ${MAVEN_DIR}
RUN alternatives --install /usr/bin/mvn maven ${MAVEN_DIR}/${MAVEN_VERSION}/bin/mvn 2
RUN echo 1 | alternatives --config maven
# Maven installation done

# Ant installation
RUN mkdir -p ${ANT_DIR}
RUN wget http://apache.mirror.colo-serv.net//ant/binaries/apache-ant-1.10.5-bin.tar.gz \
    -P ${ANT_DIR}
RUN tar xvf ${ANT_DIR}/apache*.tar.gz -C ${ANT_DIR}
RUN alternatives --install /usr/bin/ant ant ${ANT_DIR}/${ANT_VERSION}/bin/ant 2
RUN echo 1 | alternatives --config ant
# Ant installation done

# Node, npm and npx installation
RUN mkdir -p ${NODEJS_DIR}
RUN wget https://nodejs.org/dist/v10.15.0/node-v10.15.0-linux-x64.tar.xz \
    -P ${NODEJS_DIR}
RUN tar xvf ${NODEJS_DIR}/node-*.tar.xz -C ${NODEJS_DIR}
RUN alternatives --install /usr/bin/node node ${NODEJS_DIR}/${NODE_VERSION}/bin/node 2
RUN alternatives --install /usr/bin/npm npm ${NODEJS_DIR}/${NODE_VERSION}/bin/npm 2
RUN alternatives --install /usr/bin/npx npx ${NODEJS_DIR}/${NODE_VERSION}/bin/npx 2
RUN echo 1 | alternatives --config node
RUN echo 1 | alternatives --config npm
RUN echo 1 | alternatives --config npx 
# Node, npm and npx installation done

# Jenkins installation
RUN mkdir -p ${APP_HOME} ${APP_HOME}/bin ${APP_HOME}/data/.m2
RUN wget http://mirrors.jenkins.io/war-stable/latest/jenkins.war -P ${APP_HOME}/bin
# Those jars are needed to run jenkins under jdk 11
# RUN wget http://central.maven.org/maven2/javax/xml/bind/jaxb-api/2.3.0/jaxb-api-2.3.0.jar -P ${APP_HOME}/bin
# RUN wget http://central.maven.org/maven2/com/sun/xml/bind/jaxb-core/2.3.0.1/jaxb-core-2.3.0.1.jar -P ${APP_HOME}/bin
# RUN wget http://central.maven.org/maven2/com/sun/xml/bind/jaxb-impl/2.3.0.1/jaxb-impl-2.3.0.1.jar -P ${APP_HOME}/bin
# RUN wget https://github.com/javaee/activation/releases/download/JAF-1_2_0/javax.activation.jar -P ${APP_HOME}/bin
COPY ./config/jenkins/system/service.sh ${APP_HOME}/
COPY ./config/jenkins/system/.m2/settings.xml ${APP_HOME}/data/.m2/
COPY ./config/jenkins/system/.m2/settings-security.xml ${APP_HOME}/data/.m2/
RUN chmod 0750 ${APP_HOME}/service.sh
RUN groupadd -g 1002 ${APP_GROUP}
RUN useradd -r -u 1002 -M -d ${APP_HOME}/data -g ${APP_GROUP} ${APP_USER}
RUN usermod -s /sbin/nologin ${APP_USER}
RUN chown -R ${APP_USER}:${APP_GROUP} ${APP_HOME}
# Jenkins installation done

# SonarQube installation must run with jenkinsuser:jenkinsgroup
RUN mkdir ${SONARQUBE_HOME}
RUN wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-7.5.zip \
    -P ${SONARQUBE_HOME}
RUN unzip ${SONARQUBE_HOME}/sonar*.zip -d ${SONARQUBE_HOME}
RUN chown -R ${APP_USER}:${APP_GROUP} ${SONARQUBE_HOME}
# SonarQube installation done

# System configuration
COPY ./config/jenkins/system/profile.d/ant.sh /etc/profile.d/
RUN chmod 0644 /etc/profile.d/ant.sh
COPY ./config/jenkins/system/profile.d/java.sh /etc/profile.d/
RUN chmod 0644 /etc/profile.d/java.sh
COPY ./config/jenkins/system/profile.d/jenkins.sh /etc/profile.d/
RUN chmod 0644 /etc/profile.d/jenkins.sh
COPY ./config/jenkins/system/profile.d/nodejs.sh /etc/profile.d/
RUN chmod 0644 /etc/profile.d/nodejs.sh
COPY ./config/jenkins/system/profile.d/maven.sh /etc/profile.d/
RUN chmod 0644 /etc/profile.d/maven.sh
COPY ./config/jenkins/system/profile.d/sonarqube.sh /etc/profile.d/
RUN chmod 0644 /etc/profile.d/sonarqube.sh
# System configuration done

EXPOSE ${JENKINS_PORT}

# The USER instruction sets the user name (or UID) and optionally 
# the user group (or GID) to use when running the image and for 
# any RUN, CMD and ENTRYPOINT instructions that follow it in the Dockerfile.
USER ${APP_USER}

# Node container has one and only one application running. It acts as SOLID principles.
# Dokcer can't use environment variable here.
ENTRYPOINT ["/usr/share/jenkins/service.sh", "start"]
