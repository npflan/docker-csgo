FROM debian:buster-slim as vanilla

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    ca-certificates \
    lib32gcc1=1:8.3.0-6 \
    lib32stdc++6=8.3.0-6 \
    rsync \
    unzip \
    wget \
    busybox \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m csgo \
    && mkdir -p /csgo/cfg \
    && mkdir -p /scratch \
    && chown -R csgo:csgo /csgo \
    && chown -R csgo:csgo /scratch

USER csgo

RUN mkdir /home/csgo/Steam && \
    mkdir /home/csgo/server

WORKDIR /home/csgo/Steam

RUN wget -qO- https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar zxf - \
    && /home/csgo/Steam/steamcmd.sh +quit

WORKDIR /csgo

COPY start.sh ./
COPY cfg/* /csgo/cfg/

ENV PATH="/csgo/:/home/csgo:/home/csgo/server:/home/csgo/server/bin:${PATH}"
ENV LD_LIBRARY_PATH="/home/csgo:/home/csgo/bin:/home/csgo/server/:/home/csgo/server/bin:${LD_LIBRARY_PATH}"

CMD [ "/csgo/start.sh" ]


FROM vanilla as ebot

COPY ebot /csgo/addons


FROM debian:buster-slim as get5-download

RUN apt-get update && apt-get install -y wget busybox && useradd -m csgo

WORKDIR /home/csgo

ARG mmsource_exact_version="1.11.0"
ARG METAMOD_BUILD="1145"
ARG sourcemod_exact_version="1.10.0"
ARG SOURCEMOD_BUILD="6515"

# https://github.com/ErikMinekus/sm-ripext
ARG SM_RIPEXT_TAG="1.3.1"
ARG SM_RIPEXT_FILE="sm-ripext-1.3.1-linux.zip"

ARG GET5_TAG="0.7.2"
ARG GET5_FILE="get5_0.7.2.zip"

ARG GET5_APISTATS_TAG="refs/heads/master"
ARG GET5_APISTATS_FILE="get5_apistats.zip"

ARG STEAMWORKS_VERSION="git132"

RUN bash -c " \
    mmsource_version=\$(echo ${mmsource_exact_version} | cut -f1-2 -d '.'); \
    sourcemod_version=\$(echo ${sourcemod_exact_version} | cut -f1-2 -d '.'); \
    wget -qO- https://mms.alliedmods.net/mmsdrop/\${mmsource_version}/mmsource-${mmsource_exact_version}-git${METAMOD_BUILD}-linux.tar.gz | tar zxf -; \
    wget -qO- https://sm.alliedmods.net/smdrop/\${sourcemod_version}/sourcemod-${sourcemod_exact_version}-git${SOURCEMOD_BUILD}-linux.tar.gz | tar zxf -; \
    wget -qO- https://users.alliedmods.net/~kyles/builds/SteamWorks/SteamWorks-${STEAMWORKS_VERSION}-linux.tar.gz | tar zxf -; \
    wget -qO- https://github.com/ErikMinekus/sm-ripext/releases/download/${SM_RIPEXT_TAG}/${SM_RIPEXT_FILE} | busybox unzip -; \
    wget -qO- https://github.com/splewis/get5/releases/download/${GET5_TAG}/${GET5_FILE} | busybox unzip -; \
    cp -R get5/* .; rm -rf get5; \
    wget -qO- https://github.com/PhlexPlexico/get5-webapi/releases/download/${GET5_APISTATS_TAG}/${GET5_APISTATS_FILE} | busybox unzip -d addons/sourcemod/plugins -; \
    rm -f addons/metamod/sourcemod.vdf addons/metamod_x64.vdf; \
    pushd addons/sourcemod/plugins/ && mv -t disabled/ antiflood.smx basechat.smx basecomm.smx basetriggers.smx basevotes.smx clientprefs.smx funcommands.smx funvotes.smx playercommands.smx reservedslots.smx sounds.smx; \
    popd; \
    chmod -R 700 addons/sourcemod/extensions/*; \
    chown -R csgo:csgo addons"

FROM vanilla as get5

COPY --from=get5-download /home/csgo/addons/ /csgo/addons

# The vdf way of loading sourcemod didn't work, well old school then
COPY get5/metaplugins.ini /csgo/addons/metamod/