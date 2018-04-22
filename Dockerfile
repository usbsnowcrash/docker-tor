FROM alpine:3.7

ENV TOR_VER="0.3.2.10"

RUN addgroup tor && \
    adduser -D -h /opt -G tor tor && \
    echo "tor:`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 24 | mkpasswd -m sha256`" | chpasswd

RUN apk add -U --virtual deps \
        gcc g++ make libevent-dev \
        libressl-dev zlib-dev && \
    apk add libevent && \
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
    chown tor:tor -R /opt/*

CMD /bin/ash -c 'su - -s /bin/ash -c "/opt/tor/bin/tor"'