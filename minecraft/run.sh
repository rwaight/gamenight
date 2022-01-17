#!/bin/ash

if [ -z "$(cat /etc/group | grep ${PGID})"  ]; then
    addgroup -g ${PGID} minecraft;
fi

if [ -z "$(cat /etc/passwd | grep ${PUID})"  ]; then
    adduser -u ${PUID} -G minecraft -D -h /data minecraft;
fi

cat <<EOF > /data/eula.txt
#By changing the setting below to TRUE you are indicating your agreement to our EULA (https://account.mojang.com/documents/minecraft_eula).
eula=true
EOF

mkdir -p '/data/configs';
mkdir -p '/data/world';
mkdir -p '/data/plugins';

if [ -f /configs/server.properties ]; then
    cp /configs/server.properties /data/server.properties;
fi

chown -R ${PUID}:${PGID} /data;
chown -R ${PUID}:${PGID} /games;

exec su minecraft -c "java -Xmx${JVM_MEMORY_SIZE} -Xms512m ${JAVA_OPTS} -jar /games/minecraft/server.jar --nogui"
