# Ocie Version, e.g 22.04 unquoted
ARG OCIE_VERSION
    
# YourTrack Version
ARG ITSM_VERSION
    
FROM bshp/ocie:${OCIE_VERSION}
    
ARG ITSM_VERSION
ARG OCIE_VERSION

ENV OCIE_CONFIG=/etc/youtrack \
    APP_ENV="prod" \
    APP_TYPE="itsm" \
    APP_DATA=/opt/youtrack \
    APP_HOME=/usr/local/youtrack \
    APP_GROUP="jetbrains" \
    APP_OWNER="jetbrains" \
    APP_VERSION=${ITSM_VERSION} \
    APP_VOLS="/opt/youtrack/backups:/opt/youtrack/conf:/opt/youtrack/data:/opt/youtrack/logs" \
    CDN="https://download-cdn.jetbrains.com/charisma" \
    PATH=$PATH:/usr/local/youtrack/bin \
    HUB_VERSION="https://hub.docker.com/v2/namespaces/jetbrains/repositories/youtrack"
    
RUN <<"EOD" bash
    set -eu;
    # Add packages
    ocie --pkg "-base";
    useradd -m -u 13001 ${APP_OWNER};
    wget --quiet --no-cookies ${CDN}/youtrack-${APP_VERSION}.zip;
    wget --quiet --no-cookies ${CDN}/youtrack-${APP_VERSION}.zip.sha256;
    ZIP_SIG=$(echo $(cat youtrack-${APP_VERSION}.zip.sha256 | sed 's/\s.*$//') youtrack-${APP_VERSION}.zip | sha256sum -c | grep OK);
    if [[ -z "$ZIP_SIG" ]];then
        echo "Signature does not match";
        exit 1;
    fi;
    unzip -qq /youtrack-${APP_VERSION}.zip -d /usr/local;
    mv /usr/local/youtrack-${APP_VERSION} ${APP_HOME};
    rm -rf ${APP_HOME}/conf;
    mkdir -p ${APP_DATA}/backups ${APP_DATA}/conf ${APP_DATA}/data ${APP_DATA}/logs;
    ln -s ${APP_DATA}/backups ${APP_HOME}/;
    ln -s ${APP_DATA}/conf ${APP_HOME}/;
    ln -s ${APP_DATA}/data ${APP_HOME}/;
    ln -s ${APP_DATA}/logs ${APP_HOME}/;
    chown -R ${APP_OWNER}:${APP_GROUP} ${APP_DATA} ${APP_HOME} && chmod -R 0775 ${APP_DATA} ${APP_HOME};
    rm -f /youtrack-${APP_VERSION}.zip youtrack-${APP_VERSION}.zip.sha256;
    ocie --clean "-base";
    echo "System setup complete, YouTrack Version: ${APP_VERSION}";
EOD
    
COPY --chown=root:root --chmod=0755 ./src/etc/youtrack/ ./etc/youtrack/
    
EXPOSE 80 443 8080 8443
    
ENTRYPOINT ["/bin/bash"]
