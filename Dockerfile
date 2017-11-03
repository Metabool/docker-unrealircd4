FROM ubuntu:14.04

MAINTAINER  Metabool

ENV UNREALIRCD_VERSION unrealircd-4.0.15
ENV UNREAL_USER=unreal
ENV UNREAL_HOME=/home/unreal
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

WORKDIR /usr/src
RUN echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf.d/01buildconfig && \
    echo 'APT::Get::Assume-Yes "true";' >> /etc/apt/apt.conf.d/01buildconfig && \
    echo 'APT::Get::force-yes "true";' >> /etc/apt/apt.conf.d/01buildconfig  && \
    echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf.d/01buildconfig && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y build-essential curl libssl-dev ca-certificates && \
    apt-get clean

RUN useradd -m -d ${UNREAL_HOME} -s /bin/false --uid 1000 ${UNREAL_USER}

RUN mkdir -p /unrealircd_defaultconf && \
    chown -R ${UNREAL_USER}:${UNREAL_USER} /unrealircd_defaultconf 

USER ${UNREAL_USER}
RUN cd ${UNREAL_HOME} && \
    curl -s --location https://www.unrealircd.org/unrealircd4/$UNREALIRCD_VERSION.tar.gz | tar xz && \
    cd $UNREALIRCD_VERSION && \
    ./configure \
        --with-showlistmodes \
        --enable-ssl \
        --with-bindir=${UNREAL_HOME}/unrealircd/bin \
        --with-datadir=${UNREAL_HOME}/unrealircd/data \
        --with-pidfile=${UNREAL_HOME}/unrealircd/data/unrealircd.pid \
        --with-confdir=${UNREAL_HOME}/unrealircd/conf \
        --with-modulesdir=${UNREAL_HOME}/unrealircd/modules \
        --with-logdir=${UNREAL_HOME}/unrealircd/logs \
        --with-cachedir=${UNREAL_HOME}/unrealircd/cache \
        --with-docdir=${UNREAL_HOME}/unrealircd/doc \
        --with-tmpdir=${UNREAL_HOME}/unrealircd/tmp \
        --with-privatelibdir=${UNREAL_HOME}/unrealircd/lib \
        --with-scriptdir=${UNREAL_HOME}/unrealircd \
        --with-nick-history=2000 \
        --with-sendq=3000000 \
        --with-permissions=0600 \
        --with-fd-setsize=1024 \
        --enable-dynamic-linking && \
    make && \
    make install


RUN cp -Rpv ${UNREAL_HOME}/unrealircd/conf/* /unrealircd_defaultconf/
ADD openssl.cnf /unrealircd_defaultconf/ssl/openssl.cnf
ADD start /start
USER root
RUN chown ${UNREAL_USER}:${UNREAL_USER} /unrealircd_defaultconf/ssl/openssl.cnf
RUN apt-get -y remove build-essential && \
    apt-get autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/src/* /etc/unrealircd/unrealircd.conf


WORKDIR /
USER ${UNREAL_USER}
EXPOSE 6667
EXPOSE 6697
EXPOSE 7000

ENTRYPOINT ["/start"]
