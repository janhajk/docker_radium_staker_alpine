# Verwende ein modernes Basis-Image
FROM alpine:3.18

# Maintainer
LABEL maintainer="janhajk <janhajk@gmail.com>"

# Umgebungsvariablen
ENV CLIENT_URL="https://github.com/RadiumCore/radium-0.11/archive/1.5.1.0.tar.gz" \
    CLIENT_NAME="1.5.1.0"

# Installiere Abhängigkeiten
RUN apk add --no-cache \
    wget \
    nano \
    htop \
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
    qt5-qtbase-dev \
    qt5-qttools-dev \
    && rm -rf /var/cache/apk/*

# Arbeitsverzeichnis
WORKDIR /home/radium

# Kopiere Einstiegsskript
COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Erstelle Verzeichnis für Blockchain-Daten
RUN mkdir -p /home/radium/.radium

# Volume für persistente Daten
VOLUME /home/radium/.radium

# Kopiere radium.conf
COPY radium.conf /home/radium/.radium/radium.conf

# Lade und baue Radium
RUN wget --no-check-certificate -O radium.tar.gz "${CLIENT_URL}" \
    && tar xzvf radium.tar.gz \
    && rm radium.tar.gz \
    && mv radium-0.11-${CLIENT_NAME} radium \
    && cd radium/src \
    && make -f makefile.unix USE_UPNP= \
    && mv radiumd /usr/local/bin/radiumd \
    && mv radium-cli /usr/local/bin/radium-cli \
    && cd ../.. \
    && rm -rf radium

# Exponiere Standard-Ports (falls benötigt)
EXPOSE 32349

# Setze Einstiegspunkt
ENTRYPOINT ["/entrypoint.sh"]
CMD ["radiumd", "-datadir=/home/radium/.radium"]