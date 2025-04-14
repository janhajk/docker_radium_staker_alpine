FROM alpine:3.18

LABEL maintainer="janhajk <janhajk@gmail.com>"

ENV VALIDITY_VERSION=13.1.6.0
ENV VALIDITY_URL=https://github.com/RadiumCore/Validity/archive/refs/tags/${VALIDITY_VERSION}.tar.gz
ENV VALIDITY_SHA256=E4B5C1374999B31FFDD9AE6041B24C68EFAB64225CA10F1554247DC79B8FD5FC

# Installiere Build-Abhängigkeiten
RUN apk add --no-cache \
    build-base \
    wget \
    autoconf \
    automake \
    libtool \
    boost-dev \
    boost-system \
    boost-filesystem \
    boost-program_options \
    boost-thread \
    libevent-dev \
    libressl-dev \
    db-dev \
    miniupnpc-dev \
    && rm -rf /var/cache/apk/*

# Erstelle Benutzer und Verzeichnis
RUN adduser -D -u 1000 validity \
    && mkdir -p /home/validity/.validity \
    && chown -R validity:validity /home/validity/.validity

# Lade und entpacke den Quellcode
RUN cd /tmp \
    && wget --no-check-certificate -O validity.tar.gz "$VALIDITY_URL" \
    #&& echo "$VALIDITY_SHA256 validity.tar.gz" | sha256sum -c - \
    && tar -xzvf validity.tar.gz \
    && mv Validity-${VALIDITY_VERSION} /validity \
    && rm validity.tar.gz

# Patch für Boost-Kompatibilität
RUN cd /validity/src \
    && sed -i 's/context(io_service, ssl::context::sslv23)/context(ssl::context::sslv23)/g' rpcclient.cpp \
    && sed -i 's/stream\.get_io_service[[:space:]]*()/io_service/g' rpcclient.cpp

# Kompiliere Validity
RUN cd /validity \
    && ./autogen.sh \
    && ./configure --without-gui --disable-tests --disable-bench --with-incompatible-bdb \
    && make \
    && make install \
    && mv /usr/local/bin/validityd /usr/local/bin/validity-cli /usr/local/bin/ \
    && rm -rf /validity

# Kopiere Konfigurationsdatei und Entrypoint-Script
COPY validity.conf /home/validity/.validity/validity.conf
COPY entrypoint.sh /entrypoint.sh

# Setze Berechtigungen
RUN chown validity:validity /home/validity/.validity/validity.conf /entrypoint.sh \
    && chmod +x /entrypoint.sh

USER validity
WORKDIR /home/validity

VOLUME /home/validity/.validity

EXPOSE 32349

ENTRYPOINT ["/entrypoint.sh"]
CMD ["validityd", "-datadir=/home/validity/.validity"]