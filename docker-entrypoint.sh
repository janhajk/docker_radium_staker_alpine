#!/bin/sh
set -e

# Setze Standard-UID und GID, falls nicht durch Umgebungsvariablen definiert
PUID=${PUID:-1026}
PGID=${PGID:-100}

# Erstelle Gruppe und Benutzer dynamisch basierend auf PUID/PGID
if ! getent group radium >/dev/null; then
    addgroup -g "${PGID}" radium
fi

if ! id radium >/dev/null 2>&1; then
    adduser -u "${PUID}" -G radium -h /home/radium -D -s /bin/sh radium
fi

# Passe Berechtigungen von /home/radium/.radium an
chown -R radium:radium /home/radium/.radium
chmod -R u+rwX /home/radium/.radium

# Starte radiumd als Benutzer radium
echo "Starting Radium Daemon..."
exec su-exec radium radiumd -datadir=/home/radium/.radium