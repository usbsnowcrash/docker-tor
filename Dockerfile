FROM alpine:3.7

ENV TOR_VER="0.3.3.6"

RUN addgroup tor && \
    adduser -D -h /opt -G tor tor && \
    echo "tor:`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 24 | mkpasswd -m sha256`" | chpasswd

RUN apk add -U --virtual deps \
        gcc g++ make libevent-dev \
        openssl-dev zlib-dev \
        linux-headers xz-dev \
        zstd-dev libcap-dev && \
    apk add libevent libssl1.0 \
        xz zstd libcap && \
    cd ~ && \
    wget https://www.torproject.org/dist/tor-$TOR_VER.tar.gz && \
    tar xf tor-$TOR_VER.tar.gz && \
    cd tor-$TOR_VER/ && \
    ./configure --prefix=/opt/tor \
        --with-tor-user=tor \
        --with-tor-group=tor && \
    make -j$(nproc) && \
    make install && \
    rm -rf ~/* && \
    apk del --purge deps && \
    cp /opt/tor/etc/tor/torrc.sample /opt/tor/etc/tor/torrc && \
    sed -i 's/#SOCKSPort 9050/SOCKSPort 0.0.0.0:9050/' /opt/tor/etc/tor/torrc && \
    mkdir -p /opt/tor/var/lib/tor/ && \
    chown tor:tor -R /opt/*

USER tor
CMD /opt/tor/bin/tor -f /opt/tor/etc/tor/torrc
