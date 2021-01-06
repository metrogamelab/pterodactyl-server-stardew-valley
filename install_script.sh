#!/bin/bash
# Server Files: /mnt/server/
# Image to install with is 'mono:latest'
apt -y update
apt -y --no-install-recommends install curl lib32gcc1 ca-certificates wget unzip xvfb x11vnc xterm i3

## just in case someone removed the defaults.
if [ "${STEAM_USER}" == "" ]; then
    echo -e "steam user is not set.\n"
    echo -e "Using anonymous user.\n"
    STEAM_USER=anonymous
    STEAM_PASS=""
    STEAM_AUTH=""
else
    echo -e "user set to ${STEAM_USER}"
fi

## download and install steamcmd
cd /tmp
mkdir -p /mnt/server/steamcmd
mkdir -p /mnt/server/StardewValley
mkdir -p /mnt/server/nexus
mkdir -p /mnt/server/storage
mkdir -p /mnt/server/logs
curl -sSL -o steamcmd.tar.gz https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
tar -xzvf steamcmd.tar.gz -C /mnt/server/steamcmd
cd /mnt/server/steamcmd

# SteamCMD fails otherwise for some reason, even running as root.
# This is changed at the end of the install process anyways.
chown -R root:root /mnt
export HOME=/mnt/server

## install game using steamcmd
./steamcmd.sh +login ${STEAM_USER} ${STEAM_PASS} ${STEAM_AUTH} +force_install_dir /mnt/server/StardewValley +app_update ${SRCDS_APPID} validate +quit

## set up 32 bit libraries
mkdir -p /mnt/server/.steam/sdk32
cp -v linux32/steamclient.so ../.steam/sdk32/steamclient.so

## set up 64 bit libraries
mkdir -p /mnt/server/.steam/sdk64
cp -v linux64/steamclient.so ../.steam/sdk64/steamclient.so

## Stardew Valley specific setup.
wget https://github.com/Pathoschild/SMAPI/releases/download/3.8/SMAPI-3.8.0-installer.zip -qO /mnt/server/storage/nexus.zip
unzip /mnt/server/storage/nexus.zip -d /mnt/server/nexus/
/bin/bash -c "echo -e \"2\n/mnt/server/StardewValley\n1\n\" | /usr/bin/mono /mnt/server/nexus/SMAPI\ 3.8.0\ installer/internal/unix-install.exe"
wget https://raw.githubusercontent.com/metrogamelab/pterodactyl-stardew-valley-server/stardew_valley_server.config -qO /mnt/server/storage/stardew_valley_server.config
wget https://raw.githubusercontent.com/metrogamelab/pterodactyl-stardew-valley-server/i3.config -qO /mnt/server/config
wget https://github.com/metrogamelab/pterodactyl-server-stardew-valley/raw/main/alwayson.zip -qO /mnt/server/storage/alwayson.zip
wget https://github.com/metrogamelab/pterodactyl-server-stardew-valley/raw/main/unlimitedplayers.zip -qO /mnt/server/storage/unlimitedplayers.zip
wget https://github.com/metrogamelab/pterodactyl-server-stardew-valley/raw/main/autoloadgame.zip -qO //mnt/server/storage/autoloadgame.zip
unzip /mnt/server/storage/alwayson.zip -d /mnt/server/StardewValley/Mods
unzip /mnt/server/storage/unlimitedplayers.zip -d /mnt/server/StardewValley/Mods
unzip /mnt/server/storage/autoloadgame.zip -d /mnt/server/StardewValley/Mods
wget https://github.com/metrogamelab/pterodactyl-server-stardew-valley/raw/main/alwayson.json -qO /mnt/server/StardewValley/Mods/Always On Server/config.json
wget https://github.com/metrogamelab/pterodactyl-server-stardew-valley/raw/main/unlimitedplayers.json -qO /mnt/server/StardewValley/Mods/UnlimitedPlayers/config.json
wget https://github.com/metrogamelab/pterodactyl-server-stardew-valley/raw/main/autoloadgame.json -qO /mnt/server/StardewValley/Mods/AutoLoadGame/config.json
wget https://github.com/metrogamelab/pterodactyl-server-stardew-valley/raw/main/stardew-valley-server.sh -qO /mnt/server/StardewValley/stardew-valley-server.sh
chmod +x /mnt/server/StardewValley/stardew-valley-server.sh 
rm /mnt/server/storage/alwayson.zip /mnt/server/storage/unlimitedplayers.zip /mnt/server/storage/autoloadgame.zip

echo 'Stardew Valley Installation complete. Restart server.'