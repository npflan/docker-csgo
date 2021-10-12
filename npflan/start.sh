#!/bin/bash

if [ ! -n "$POD_NAME" ]; then
    echo "POD_NAME is not set, check your manifest"
    exit 1
fi

CSGOFOLDER="$POD_NAME"

if [ ! -d $CSGOFOLDER ]; then
    mkdir -p /scratch/$CSGOFOLDER
    ln -snf /scratch/$CSGOFOLDER /csgo/csgo
fi


# Check if /csgo/addons exists
if [[ -d /csgo/addons ]]; then
    ln -snf /csgo/addons /csgo/csgo/addons
fi
ln -snf /csgo/cfg /csgo/csgo/cfg
ln -snf /home/csgo/server/srcds_run /csgo/srcds_run
ln -snf /home/csgo/server/srcds_linux /csgo/srcds_linux
ln -snf /home/csgo/server/bin /csgo/bin

# Create symlinks to srcds files
for a in `ls /home/csgo/server/csgo|grep -v console.log|grep -v addons|grep -v cfg`; do
    ln -snf /home/csgo/server/csgo/$a /csgo/csgo/$a
done

GAMESERVERTOKEN=`wget -qO- $GSLT_URL/$POD_NAME`

if [ -n "$GAMESERVERTOKEN" ]; then
    echo "Gameservertoken: $GAMESERVERTOKEN"
    CSGO_GSLT=$GAMESERVERTOKEN
fi

additionalParams=""

if [ -n "$CSGO_GSLT" ]; then
    additionalParams+=" +sv_setsteamaccount $CSGO_GSLT"
else
    echo '> Warning: Environment variable "CSGO_GSLT" is not set, but is required to run the server on the internet. Running the server in LAN mode instead.'
    additionalParams+=" +sv_lan 1"
fi

if [ -n "$CSGO_PW" ]; then
    additionalParams+=" +sv_password $CSGO_PW"
fi

if [ -n "$CSGO_HOSTNAME" ]; then
    additionalParams+=" +hostname $CSGO_HOSTNAME"
    additionalParams+=
fi

if [ -n "$CSGO_WS_API_KEY" ]; then
    additionalParams+=" -authkey $CSGO_WS_API_KEY"
fi

if [ "${CSGO_FORCE_NETSETTINGS-"false"}" = "true" ]; then
    additionalParams+=" +sv_minrate 786432 +sv_mincmdrate 128 +sv_minupdaterate 128"
fi

if [ "${CSGO_TV_ENABLE-"false"}" = "true" ]; then
    additionalParams+=" +tv_enable 1"
    additionalParams+=" +tv_delaymapchange ${CSGO_TV_DELAYMAPCHANGE-1}"
    additionalParams+=" +tv_delay ${CSGO_TV_DELAY-45}"
    additionalParams+=" +tv_deltacache ${CSGO_TV_DELTACACHE-2}"
    additionalParams+=" +tv_dispatchmode ${CSGO_TV_DISPATCHMODE-1}"
    additionalParams+=" +tv_maxclients ${CSGO_TV_MAXCLIENTS-10}"
    additionalParams+=" +tv_maxrate ${CSGO_TV_MAXRATE-0}"
    additionalParams+=" +tv_overridemaster ${CSGO_TV_OVERRIDEMASTER-0}"
    additionalParams+=" +tv_snapshotrate ${CSGO_TV_SNAPSHOTRATE-128}"
    additionalParams+=" +tv_timeout ${CSGO_TV_TIMEOUT-60}"
    additionalParams+=" +tv_transmitall ${CSGO_TV_TRANSMITALL-1}"

    if [ -n "${CSGO_TV_NAME}" ]; then
        additionalParams+=" +tv_name ${CSGO_TV_NAME}"
    fi

    if [ -n "${CSGO_TV_PORT}" ]; then
        additionalParams+=" +tv_port ${CSGO_TV_PORT}"
    fi

    if [ -n "${CSGO_TV_PASSWORD}" ]; then
        additionalParams+=" +tv_password ${CSGO_TV_PASSWORD}"
    fi
fi

/csgo/srcds_run \
    -secure \
    -condebug \
    -binary /csgo/srcds_linux \
    -game csgo \
    -console \
    -norestart \
    -usercon \
    -nobreakpad \
    +ip "${CSGO_IP-0.0.0.0}" \
    -port "${CSGO_PORT-27015}" \
    -tickrate "${CSGO_TICKRATE-128}" \
    -maxplayers_override "${CSGO_MAX_PLAYERS-16}" \
    +game_type "${CSGO_GAME_TYPE-0}" \
    +game_mode "${CSGO_GAME_MODE-1}" \
    +mapgroup "${CSGO_MAP_GROUP-mg_active}" \
    +map "${CSGO_MAP-de_dust2}" \
    +rcon_password "${CSGO_RCON_PW-changeme}" \
    $additionalParams \
    $CSGO_PARAMS