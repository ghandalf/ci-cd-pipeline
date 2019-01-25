FROM centos

LABEL Author="Francis Ouellet <fouellet@dminc.com>"
LABEL Description="Base on Centos 7"

ENV CONTAINER_NAME subversion
ENV CONTAINER_IMAGE ghandalf/subversion:${CONTAINERS_VERSION}
ENV CONTAINER_VERSION ${CONTAINERS_VERSION}
ENV APP_USER subversion
ENV APP_GROUP sgroup
ENV APP_HOME /usr/share/subversion

ENV SUBVERSION_VERSION 1.11.1
ENV SUBVERSION_HOME ${APP_HOME}/subversion-${SUBVERSION_VERSION}
ENV SUBVERSION_DATA ${SUBVERSION_HOME}/data
ENV SUBVERSION_PORT 32182

ENV APR_DIR /usr/share/apr
ENV APR_VERSION 1.6.5
ENV APR_HOME ${APR_DIR}/apr-${APR_VERSION}

ENV SQLITE_DIR /usr/share/sqlite
ENV SERF_DIR /usr/share/serf
ENV SCONS_DIR /usr/share/scons

ENV LD_LIBRARY_PATH /usr/local/apr/lib:/usr/local/apr-util/lib:/usr/local/lib:/usr/local/serf/lib:/usr/lib/python3.7/site-packages/SCons:/usr/include/serf-1
ENV LD_RUN_PATH /usr/local/apr/lib:/usr/local/apr-util/lib:/usr/local/lib:/usr/local/serf/lib:/usr/lib/python3.7/site-packages/SCons:/usr/include/serf-1

# RUN yum -y update
# RUN yum --security check-update
# RUN yum --security update
RUN yum install -y bind-utils mailx net-tools tree wget

# Use to compile and deploy Subversion source code
RUN yum groupinstall -y "Development Tools"
RUN yum install -y libtool openssl-devel perl-core zlib-devel 
# Use to compile APR, APR-Util, SCons and Serf
RUN yum install -y pcre-devel expat-devel 
RUN yum install -y centos-release-scl rh-python36
RUN yum clean all

# Installing Apache Portable Runtime (APR)
RUN mkdir -p ${APR_DIR}
RUN wget http://apache.mirror.globo.tech//apr/apr-1.6.5.tar.gz -P ${APR_DIR}
RUN tar xvf ${APR_DIR}/apr*.tar.gz -C ${APR_DIR}/
RUN cd ${APR_DIR}/apr-1.6.5 && ./configure && make && make install
COPY ./config/subversion/system/ld.so.conf.d/apr.conf /etc/ld.so.conf.d/
# Installing Apache Portable Runtime (APR) done

# Installing Apache Portable Runtime Util (APR-Util)
RUN wget http://apache.mirror.globo.tech//apr/apr-util-1.6.1.tar.gz -P ${APR_DIR}
RUN tar xvf ${APR_DIR}/apr-util*.tar.gz -C ${APR_DIR}/
RUN cd ${APR_DIR}/apr-util-1.6.1 \
    && ./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr/bin/apr-1-config \
    && make && make install
COPY ./config/subversion/system/ld.so.conf.d/apr-util.conf /etc/ld.so.conf.d/
# Installing Apache Portable Runtime Util (APR-Util) done

# Installing SQLite latest version Subversion needs at least 3.8.2
RUN mkdir ${SQLITE_DIR}
RUN wget https://www.sqlite.org/2018/sqlite-autoconf-3260000.tar.gz -P ${SQLITE_DIR}
RUN tar xvf ${SQLITE_DIR}/sqlite*.tar.gz -C ${SQLITE_DIR}/
RUN cd ${SQLITE_DIR}/sqlite-autoconf-3260000 \
    && ./configure \
    && make && make install
COPY ./config/subversion/system/ld.so.conf.d/sqlite.conf /etc/ld.so.conf.d/
# Installing SQLite done

# Installing SCons
RUN mkdir ${SCONS_DIR}
RUN wget https://downloads.sourceforge.net/scons/scons-3.0.4.tar.gz -P ${SCONS_DIR}
RUN tar xvf ${SCONS_DIR}/scons-*.tar.gz -C ${SCONS_DIR}/
RUN sed "s/enabled=1/enabled=0/" /etc/yum/pluginconf.d/fastestmirror.conf
RUN yum clean all
RUN yum -y update
RUN yum install -y python36
RUN cd ${SCONS_DIR}/scons-3.0.4 \
    && sed -i 's/env python/&3/' script/scons*  \
    && python3 setup.py install --prefix=/usr  \
                         --standard-lib \
                         --optimize=1   \
                         --install-data=/usr/share \
    && rm -v /usr/bin/scons*.bat
COPY ./config/subversion/system/ld.so.conf.d/scons.conf /etc/ld.so.conf.d/
# Installing SCons done

# Installing serf
RUN mkdir ${SERF_DIR}
RUN wget https://www.apache.org/dist/serf/serf-1.3.9.tar.bz2 -P ${SERF_DIR}
RUN tar xvf ${SERF_DIR}/serf-*.tar.bz2 -C ${SERF_DIR}/
RUN cd ${SERF_DIR}/serf-1.3.9 \
    && sed -i "/Append/s:RPATH=libdir,::"   SConstruct \
    && sed -i "/Default/s:lib_static,::"           SConstruct \
    && sed -i "/Alias/s:install_static,::"         SConstruct \
    && sed -i "/  print/{s/print/print(/; s/$/)/}" SConstruct \
    && sed -i "/get_contents()/s/,/.decode()&/"    SConstruct \
    && scons PREFIX=/usr# Installing serf done
RUN scons PREFIX=/usr install
COPY ./config/subversion/system/ld.so.conf.d/serf.conf /etc/ld.so.conf.d/
# Installing serf done

# Then verify the signatures as follows: do
# % gpg --import serf.asc
# % gpg --verify serf-1.3.9.tar.bz2.asc

# Subversion installation
RUN scl enable rh-python36 bash
RUN mkdir -p ${APP_HOME} ${APP_HOME}/data/logs
RUN wget http://apache.mirror.globo.tech/subversion/subversion-1.11.1.tar.gz -P ${APP_HOME}
RUN tar xvf ${APP_HOME}/*.tar.gz -C ${APP_HOME}
RUN cd ${SUBVERSION_HOME} \
    && ./configure --with-apr-util=/usr/local/apr-util/bin \
    && make && make install
# Subversion installation done

# RUN alternatives --install /usr/bin/java java ${JAVA_DIR}/${JAVA_VERSION}/bin/java 2
# RUN echo 1 | alternatives --config java
# RUN alternatives --install /usr/bin/jar jar ${JAVA_DIR}/${JAVA_VERSION}/bin/jar 2
# RUN alternatives --install /usr/bin/javac javac ${JAVA_DIR}/${JAVA_VERSION}/bin/javac 2
# RUN alternatives --set jar ${JAVA_DIR}/${JAVA_VERSION}/bin/jar
# RUN alternatives --set javac ${JAVA_DIR}/${JAVA_VERSION}/bin/javac
# RUN svn -version

# System configuration
COPY ./config/subversion/system/service.sh ${APP_HOME}
RUN chmod 0755 ${APP_HOME}/service.sh
COPY ./config/subversion/system/profile.d/subversion.sh /etc/profile.d/
RUN chmod 0644 /etc/profile.d/subversion.sh
# System configuration done

RUN groupadd -g 1002 ${APP_GROUP}
RUN useradd -r -u 1002 -M -b ${APP_HOME}} -g ${APP_GROUP} ${APP_USER}
RUN usermod -s /sbin/nologin ${APP_USER}
RUN chown -R ${APP_USER}:${APP_GROUP} ${APP_HOME}
# Subversion installation done



EXPOSE ${SUBVERSION_PORT}

# The USER instruction sets the user name (or UID) and optionally 
# the user group (or GID) to use when running the image and for 
# any RUN, CMD and ENTRYPOINT instructions that follow it in the Dockerfile.
USER ${APP_USER}

# TODO: https://subversion.apache.org/download.cgi#verifying
ENTRYPOINT ["/usr/share/subversion/service.sh", "start"]
