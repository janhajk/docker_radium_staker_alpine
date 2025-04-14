FROM debian:stretch-slim

LABEL maintainer="janhajk <janhajk@gmail.com>"

ENV VALIDITY_VERSION=13.1.6.0
ENV VALIDITY_URL=https://github.com/RadiumCore/Validity/archive/refs/tags/${VALIDITY_VERSION}.tar.gz
ENV VALIDITY_SHA256=deine_sha256_pruefsumme_hier

# Installiere Build-Abhängigkeiten
RUN echo "deb http://archive.debian.org/debian stretch main" > /etc/apt/sources.list \
    && echo "deb http://archive.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list \
    && apt-get update \
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
       libminiupnpc-dev \
    && rm -rf /var/lib/apt/lists/*

# Installiere Berkeley DB 4.8
RUN cd /tmp \
    && wget -qO db-4.8.30.NC.tar.gz http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz \
    && echo "12edc0df75bf9abd7f82f821795bcee50f42cb2e5f76a6a281b85732798364 db-4.8.30.NC.tar.gz" | sha256sum -c - \
    && tar -xzvf db-4.8.30.NC.tar.gz \
    && cd db-4.8.30.NC/build_unix \
    && ../dist/configure --prefix=/usr/local --enable-cxx \
    && make \
    && make install \
    && rm -rf /tmp/db-4.8.30.NC*

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
    && ./configure --without-gui --disable-tests --disable-bench \
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