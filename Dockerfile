FROM ubuntu:18.04

####################
# Dependency
####################

RUN dpkg --add-architecture i386 && \
    apt-get update && apt-get upgrade -y && \
    apt-get install -y curl tar ca-certificates lib32gcc1 lib32stdc++6 libcurl4-gnutls-dev:i386 && \
    apt-get autoremove --purge -y wget && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

####################
# SteamCMD
####################

ENV STEAMCMD_ROOT=/root/steamcmd
RUN mkdir -p "${STEAMCMD_ROOT}" && \
    cd "${STEAMCMD_ROOT}" && \
    curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -
# Update SteamCMD and verify latest version
RUN ${STEAMCMD_ROOT}/steamcmd.sh \
    +@ShutdownOnFailedCommand 1 \
    +@NoPromptForPassword 1 \
    +login anonymous \
    +quit

####################
# DST
####################

ENV DST_ROOT=/root/dst
RUN mkdir -p "${DST_ROOT}"

# [Optional] Install Don't Starve Together as init
RUN taskset -c 0 ${STEAMCMD_ROOT}/steamcmd.sh \
    +@ShutdownOnFailedCommand 1 \
    +@NoPromptForPassword 1 \
    +login anonymous \
    +force_install_dir ${DST_ROOT} \
    +app_update 343050 validate \
    +quit

ENV CLUSTER_NAME=MyDediServer

# Create exec script
RUN mkdir -p ${DST_ROOT}/bin && \
    cd ${DST_ROOT}/bin && \
    echo "${STEAMCMD_ROOT}/steamcmd.sh +@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir ${DST_ROOT} +app_update 343050 +quit" >> start.sh && \
    echo "./dontstarve_dedicated_server_nullrenderer -console -cluster ${CLUSTER_NAME} -shard \$SHARD_NAME" >> start.sh && \
    chmod +x start.sh

VOLUME /root/.klei/DoNotStarveTogether/${CLUSTER_NAME}
VOLUME ${DST_ROOT}/mods
VOLUME ${DST_ROOT}/ugc_mods

WORKDIR ${DST_ROOT}/bin
CMD "./start.sh"
