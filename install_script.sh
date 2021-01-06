#!/bin/bash
# Server Files: /mnt/server/
# Image to install with is 'mono:latest'

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

## setup the directory stucture
mkdir -p /home/container/StardewValley
mkdir -p /home/container/nexus
mkdir -p /home/container/storage
mkdir -p /home/container/logs

## install game using steamcmd
steamcmd +login ${STEAM_USER} ${STEAM_PASS} ${STEAM_AUTH} +force_install_dir /home/container +app_update ${SRCDS_APPID} validate +quit

## set up 32 bit libraries
mkdir -p /home/container/.steam/sdk32
cp -v /home/container/steamcmd/linux32/steamclient.so /home/container/.steam/sdk32/steamclient.so

## set up 64 bit libraries
mkdir -p /home/container/.steam/sdk64
cp -v /home/container/steamcmd/linux64/steamclient.so /home/container/.steam/sdk64/steamclient.so

## Stardew Valley specific setup.
wget https://github.com/Pathoschild/SMAPI/releases/download/3.8/SMAPI-3.8.0-installer.zip -qO /home/container/storage/nexus.zip
unzip /home/container/storage/nexus.zip -d /home/container/nexus/
/bin/bash -c "echo -e \"2\n/home/container\n1\n\" | /usr/bin/mono /home/container/nexus/SMAPI\ 3.8.0\ installer/internal/unix-install.exe"
wget https://raw.githubusercontent.com/metrogamelab/pterodactyl-stardew-valley-server/stardew_valley_server.config -qO /home/container/storage/stardew_valley_server.config
wget https://raw.githubusercontent.com/metrogamelab/pterodactyl-stardew-valley-server/i3.config -qO /home/container/config
wget https://raw.githubusercontent.com/metrogamelab/pterodactyl-stardew-valley-server/alwayson.zip -qO /home/container/storage/alwayson.zip
wget https://raw.githubusercontent.com/metrogamelab/pterodactyl-stardew-valley-server/unlimitedplayers.zip -qO /home/container/storage/unlimitedplayers.zip
wget https://raw.githubusercontent.com/metrogamelab/pterodactyl-stardew-valley-server/autoloadgame.zip -qO /home/container/storage/autoloadgame.zip
unzip /home/container/storage/alwayson.zip -d /home/container/Mods
unzip /home/container/storage/unlimitedplayers.zip -d /home/container/Mods
unzip /home/container/storage/autoloadgame.zip -d /home/container/Mods
wget https://raw.githubusercontent.com/metrogamelab/pterodactyl-stardew-valley-server/alwayson.json -qO /home/container/Mods/Always On Server/config.json
wget https://raw.githubusercontent.com/metrogamelab/pterodactyl-stardew-valley-server/unlimitedplayers.json -qO /home/container/Mods/UnlimitedPlayers/config.json
wget https://raw.githubusercontent.com/metrogamelab/pterodactyl-stardew-valley-server/autoloadgame.json -qO /home/container/Mods/AutoLoadGame/config.json
wget https://raw.githubusercontent.com/metrogamelab/pterodactyl-stardew-valley-server/stardew-valley-server.sh -qO /home/container/stardew-valley-server.sh
chmod +x /home/container/stardew-valley-server.sh 
rm /home/container/storage/alwayson.zip /home/container/storage/unlimitedplayers.zip /home/container/storage/autoloadgame.zip

echo 'Stardew Valley Installation complete. Restart server.'