FROM ubuntu:14.04

MAINTAINER  Metabool

ENV UNREALIRCD_VERSION unrealircd-4.0.15
ENV UNREAL_USER=unreal
ENV UNREAL_HOME=/unreal
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
    apt-get clean && \
    curl -s --location https://www.unrealircd.org/unrealircd4/$UNREALIRCD_VERSION.tar.gz | tar xz && \
    cd $UNREALIRCD_VERSION && \
    ./configure \
	--with-showlistmodes \
	--enable-ssl \
	--with-bindir=/usr/local/unrealircd/bin \
	--with-datadir=/usr/local/unrealircd/data \ 
	--with-pidfile=/usr/local/unrealircd/data/unrealircd.pid \
	--with-confdir=/usr/local/unrealircd/conf \
	--with-modulesdir=/usr/local/unrealircd/modules \
	--with-logdir=/usr/local/unrealircd/logs \
	--with-cachedir=/usr/local/unrealircd/cache \
	--with-docdir=/usr/local/unrealircd/doc \
	--with-tmpdir=/usr/local/unrealircd/tmp \
	--with-privatelibdir=/usr/local/unrealircd/lib \
	--with-scriptdir=/usr/local/unrealircd \
	--with-nick-history=2000 \
	--with-sendq=3000000 \
	--with-permissions=0600 \
	--with-fd-setsize=1024 \
	--enable-dynamic-linking && \
    make && \
    make install && \
    apt-get -y remove build-essential && \
    apt-get autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/src/* /etc/unrealircd/unrealircd.conf

RUN useradd -M -s /bin/false --uid 1000 ${UNREAL_USER}

RUN mkdir -p /unrealircd_defaultconf && \
    chown -R ${UNREAL_USER}:${UNREAL_USER} /usr/local/unrealircd/* && \
    chown -R ${UNREAL_USER}:${UNREAL_USER} /usr/local/unrealircd/ && \
    chown -R ${UNREAL_USER}:${UNREAL_USER} /unrealircd_defaultconf 

RUN ls -lha /usr/local/unrealircd/conf/
USER ${UNREAL_USER}

ADD openssl.cnf /usr/local/unrealircd/conf/ssl/openssl.cnf
ADD start /start
RUN ls -lha /usr/local/
RUN ls -lha /usr/local/unrealircd/conf/
RUN cp -Rpv /usr/local/unrealircd/conf/* /unrealircd_defaultconf/

WORKDIR /
USER ${UNREAL_USER}
EXPOSE 6667
EXPOSE 6697
EXPOSE 7000

ENTRYPOINT ["/start"]
