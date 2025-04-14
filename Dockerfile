FROM alpine:3.11

LABEL maintainer="janhajk <janhajk@gmail.com>"

ENV CLIENT_URL="https://github.com/RadiumCore/radium-0.11/archive/1.5.1.0.tar.gz" \
    CLIENT_NAME="1.5.1.0"

# Installiere Abhängigkeiten
RUN apk add --no-cache \
    wget \
    build-base \
    boost-dev \
    boost-system \
    boost-filesystem \
    boost-program_options \
    boost-thread \
    libevent-dev \
    libressl-dev \
    db-dev \
    miniupnpc-dev \
    su-exec \
    && rm -rf /var/cache/apk/*

WORKDIR /home/radium

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN mkdir -p /home/radium/.radium

VOLUME /home/radium/.radium

COPY radium.conf /home/radium/.radium/radium.conf

# Lade, patch und baue den Quellcode
RUN wget --no-check-certificate -O radium.tar.gz "${CLIENT_URL}" \
    && tar xzvf radium.tar.gz \
    && rm radium.tar.gz \
    && mv radium-0.11-${CLIENT_NAME} radium \
    && cd radium/src \
    && sed -i 's/context(io_service, ssl::context::sslv23)/context(ssl::context::sslv23)/g' rpcclient.cpp \
    && sed -i 's/stream\.get_io_service()/io_service/g' rpcclient.cpp \
    && grep -C 2 "boost::asio::ip::tcp::resolver" rpcclient.cpp || echo "Patch failed" \
    && make -f makefile.unix USE_UPNP= \
    && mv radiumd /usr/local/bin/radiumd \
    && mv radium-cli /usr/local/bin/radium-cli \
    && cd ../.. \
    && rm -rf radium

EXPOSE 32349

ENTRYPOINT ["/entrypoint.sh"]
CMD ["radiumd", "-datadir=/home/radium/.radium"]