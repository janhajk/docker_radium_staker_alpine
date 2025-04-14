FROM debian:buster-slim

LABEL maintainer="janhajk <janhajk@gmail.com>"

ENV VALIDITY_VERSION=13.1.6
ENV VALIDITY_URL=https://codeload.github.com/RadiumCore/Validity/tar.gz/refs/tags/13.1.6.0
ENV VALIDITY_SHA256=E4B5C1374999B31FFDD9AE6041B24C68EFAB64225CA10F1554247DC79B8FD5FC

# Installiere Abhängigkeiten
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates \
       wget \
    && rm -rf /var/lib/apt/lists/*

# Erstelle Benutzer und Verzeichnis
RUN useradd -m -u 1000 validity \
    && mkdir -p /home/validity/.validity \
    && chown -R validity:validity /home/validity/.validity

# Lade und verifiziere Validity-Binaries
RUN cd /tmp \
    && wget -qO validity.tar.gz "$VALIDITY_URL" \
    && echo "$VALIDITY_SHA256 validity.tar.gz" | sha256sum -c - \
    && tar -xzvf validity.tar.gz -C /usr/local/bin --strip-components=2 validity-${VALIDITY_VERSION}/bin/validityd validity-${VALIDITY_VERSION}/bin/validity-cli \
    && rm validity.tar.gz

# Kopiere Konfigurationsdatei und Entrypoint-Script
COPY validity.conf /home/validity/.validity/validity.conf
COPY entrypoint.sh /entrypoint.sh

# Setze Berechtigungen für Entrypoint-Script
RUN chown validity:validity /home/validity/.validity/validity.conf /entrypoint.sh \
    && chmod +x /entrypoint.sh

USER validity
WORKDIR /home/validity

VOLUME /home/validity/.validity

EXPOSE 32349

ENTRYPOINT ["/entrypoint.sh"]
CMD ["validityd", "-datadir=/home/validity/.validity"]