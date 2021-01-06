#!/bin/bash
# steamcmd Base Installation Script
#
# Server Files: /mnt/server
# Image to install with is 'mono:latest'
apt -y update
apt -y --no-install-recommends install curl lib32gcc1 ca-certificates wget unzip

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
./steamcmd.sh +login ${STEAM_USER} ${STEAM_PASS} ${STEAM_AUTH} +force_install_dir /mnt/server +app_update ${SRCDS_APPID} validate +quit

## set up 32 bit libraries
mkdir -p /mnt/server/.steam/sdk32
cp -v linux32/steamclient.so ../.steam/sdk32/steamclient.so

## set up 64 bit libraries
mkdir -p /mnt/server/.steam/sdk64
cp -v linux64/steamclient.so ../.steam/sdk64/steamclient.so

## Game specific setup.
cd /mnt/server/
## setup the directory stucture
mkdir -p ./StardewValley
mkdir -p ./nexus
mkdir -p ./storage
mkdir -p ./logs

## Stardew Valley specific setup.
wget https://github.com/Pathoschild/SMAPI/releases/download/3.8/SMAPI-3.8.0-installer.zip -qO ./storage/nexus.zip
unzip ./storage/nexus.zip -d ./nexus/
/bin/bash -c "echo -e \"2\n/mnt/server\n1\n\" | /usr/bin/mono /mnt/server/nexus/SMAPI\ 3.8.0\ installer/internal/unix-install.exe"
wget https://raw.githubusercontent.com/metrogamelab/pterodactyl-stardew-valley-server/stardew_valley_server.config -qO ./storage/stardew_valley_server.config
wget https://raw.githubusercontent.com/metrogamelab/pterodactyl-stardew-valley-server/i3.config -qO ./config
wget https://raw.githubusercontent.com/metrogamelab/pterodactyl-stardew-valley-server/alwayson.zip -qO ./storage/alwayson.zip
wget https://raw.githubusercontent.com/metrogamelab/pterodactyl-stardew-valley-server/unlimitedplayers.zip -qO ./storage/unlimitedplayers.zip
wget https://raw.githubusercontent.com/metrogamelab/pterodactyl-stardew-valley-server/autoloadgame.zip -qO ./storage/autoloadgame.zip
unzip ./storage/alwayson.zip -d ./Mods
unzip ./unlimitedplayers.zip -d ./Mods
unzip ./autoloadgame.zip -d ./Mods
wget https://raw.githubusercontent.com/metrogamelab/pterodactyl-stardew-valley-server/alwayson.json -qO ./Mods/Always On Server/config.json
wget https://raw.githubusercontent.com/metrogamelab/pterodactyl-stardew-valley-server/unlimitedplayers.json -qO ./Mods/UnlimitedPlayers/config.json
wget https://raw.githubusercontent.com/metrogamelab/pterodactyl-stardew-valley-server/autoloadgame.json -qO ./Mods/AutoLoadGame/config.json
wget https://raw.githubusercontent.com/metrogamelab/pterodactyl-stardew-valley-server/stardew-valley-server.sh -qO ./stardew-valley-server.sh
chmod +x ./stardew-valley-server.sh 
rm ./storage/alwayson.zip ./storage/unlimitedplayers.zip ./storage/autoloadgame.zip

echo 'Stardew Valley Installation complete. Restart server.'