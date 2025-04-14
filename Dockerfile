FROM debian:buster-slim

LABEL maintainer="Jan Schär <janhajk@gmail.com>"

ENV VALIDITY_VERSION=13.1.6.0
ENV VALIDITY_URL=[invalid url, do not cite]
ENV VALIDITY_SHA256=dein_sha256_hier  # Ersetze mit tatsächlichem SHA256

RUN set -ex \
    && apt-get update \
    && apt-get install -qq --no-install-recommends ca-certificates wget \
    && rm -rf /var/lib/apt/lists/*

RUN set -ex \
    && cd /tmp \
    && wget -qO validity.tar.gz "$VALIDITY_URL" \
    && echo "$VALIDITY_SHA256 validity.tar.gz" | sha256sum -c - \
    && tar -xzvf validity.tar.gz -C /usr/local --strip-components=1 --exclude=*-qt

USER 1000

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]