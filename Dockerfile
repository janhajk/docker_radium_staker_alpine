FROM debian:stretch-slim

LABEL maintainer="janhajk <janhajk@gmail.com>"

ENV VALIDITY_VERSION=13.1.6.0
ENV VALIDITY_URL=https://github.com/RadiumCore/Validity/archive/refs/tags/${VALIDITY_VERSION}.tar.gz
ENV VALIDITY_SHA256=E4B5C1374999B31FFDD9AE6041B24C68EFAB64225CA10F1554247DC79B8FD5FC

# Installiere Build-Abhängigkeiten
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       build-essential \
       ca-certificates \
       wget \
       pkg-config \
       autoconf \
       automake \
       libtool \
       libssl-dev \
       libevent-dev \
       libboost-system-dev \
       libboost-filesystem-dev \
       libboost-program-options-dev \
       libboost-thread-dev \
       libdb5.3-dev \
       libminiupnpc-dev \
    && rm -rf /var/lib/apt/lists/*

# Erstelle Benutzer und Verzeichnis
RUN useradd -m -u 1000 validity \
    && mkdir -p /home/validity/.validity \
    && chown -R validity:validity /home/validity/.validity

# Lade und entpacke den Quellcode
RUN cd /tmp \
    && wget -qO validity.tar.gz "$VALIDITY_URL" \
    && echo "$VALIDITY_SHA256 validity.tar.gz" | sha256sum -c - \
    && tar -xzvf validity.tar.gz \
    && mv Validity-${VALIDITY_VERSION} /validity \
    && rm validity.tar.gz

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