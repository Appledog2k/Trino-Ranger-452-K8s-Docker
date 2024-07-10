#!/bin/bash
microdnf install gzip -y
microdnf install dos2unix -y
microdnf install findutils -y
RANGER_VERSION=ranger-2.4.0-trino-plugin
TAR_FILE=/root/${RANGER_VERSION}.tar.gz
cd /root

# Check if the tar file exists
if [ -f "$TAR_FILE" ]; then
    echo "Tar file $TAR_FILE already exists."
else
    echo "Tar file $TAR_FILE does not exist. Downloading from $DOWNLOAD_URL..."
    curl -k https://github.com/gympass/apache-ranger/releases/download/plugin-trino-451/${RANGER_VERSION}.tar.gz --output ${RANGER_VERSION}.tar.gz -L
    echo "Download completed."
fi
mkdir -p /root/${RANGER_VERSION} && \
tar xvf ${RANGER_VERSION}.tar.gz -C /root/${RANGER_VERSION} --strip-components 1 && \
yes | cp -rf /root/install.properties /root/${RANGER_VERSION}/ && \
chown root:root -R /root/${RANGER_VERSION}/* && \
find /root -type f -exec dos2unix {} \; && \
/root/${RANGER_VERSION}/enable-trino-plugin.sh && \
/usr/lib/trino/bin/run-trino
