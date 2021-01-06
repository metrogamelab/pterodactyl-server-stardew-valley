#!/bin/bash
# Server Files: /home/container/StardewValley
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
curl -sSL -o steamcmd.tar.gz https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
tar -xzvf steamcmd.tar.gz -C /mnt/server/steamcmd
cd /mnt/server/steamcmd

# SteamCMD fails otherwise for some reason, even running as root.
# This is changed at the end of the install process anyways.
chown -R root:root /mnt
export HOME=/mnt/server

## install game using steamcmd
./steamcmd.sh +login ${STEAM_USER} ${STEAM_PASS} ${STEAM_AUTH} +force_install_dir /home/container/StardewValley +app_update ${SRCDS_APPID} validate +quit

## set up 32 bit libraries
mkdir -p /mnt/server/.steam/sdk32
cp -v linux32/steamclient.so ../.steam/sdk32/steamclient.so

## set up 64 bit libraries
mkdir -p /mnt/server/.steam/sdk64
cp -v linux64/steamclient.so ../.steam/sdk64/steamclient.so

## Stardew Valley specific setup.
cd /home/container/StardewValley
mkdir -p /home/container/nexus
mkdir -p /home/container/storage
mkdir -p /home/container/logs
wget https://github.com/Pathoschild/SMAPI/releases/download/3.8/SMAPI-3.8.0-installer.zip -qO /home/container/storage/nexus.zip
unzip /home/container/storage/nexus.zip -d /home/container/nexus/
/bin/bash -c "echo -e \"2\n/home/container/StardewValley\n1\n\" | /usr/bin/mono /home/container/nexus/SMAPI\ 3.8.0\ installer/internal/unix-install.exe"
wget https://raw.githubusercontent.com/metrogamelab/pterodactyl-stardew-valley-server/stardew_valley_server.config -qO /home/container/storage/stardew_valley_server.config
wget https://raw.githubusercontent.com/metrogamelab/pterodactyl-stardew-valley-server/i3.config -qO /home/container/config
wget https://github.com/metrogamelab/pterodactyl-server-stardew-valley/raw/main/alwayson.zip -qO /home/container/storage/alwayson.zip
wget https://github.com/metrogamelab/pterodactyl-server-stardew-valley/raw/main/unlimitedplayers.zip -qO /home/container/storage/unlimitedplayers.zip
wget https://github.com/metrogamelab/pterodactyl-server-stardew-valley/raw/main/autoloadgame.zip -qO /home/container/storage/autoloadgame.zip
unzip /home/container/storage/alwayson.zip -d /home/container/StardewValley/Mods
unzip /home/container/storage/unlimitedplayers.zip -d /home/container/StardewValley/Mods
unzip /home/container/storage/autoloadgame.zip -d /home/container/StardewValley/Mods
wget https://github.com/metrogamelab/pterodactyl-server-stardew-valley/raw/main/alwayson.json -qO /home/container/StardewValley/Mods/Always On Server/config.json
wget https://github.com/metrogamelab/pterodactyl-server-stardew-valley/raw/main/unlimitedplayers.json -qO /home/container/StardewValley/Mods/UnlimitedPlayers/config.json
wget https://github.com/metrogamelab/pterodactyl-server-stardew-valley/raw/main/autoloadgame.json -qO /home/container/StardewValley/Mods/AutoLoadGame/config.json
wget https://github.com/metrogamelab/pterodactyl-server-stardew-valley/raw/main/stardew-valley-server.sh -qO /home/container/StardewValley/stardew-valley-server.sh
chmod +x /home/container/StardewValley/stardew-valley-server.sh 
rm /home/container/storage/alwayson.zip /home/container/storage/unlimitedplayers.zip /home/container/storage/autoloadgame.zip

echo 'Stardew Valley Installation complete. Restart server.'