FROM trinodb/trino:452

USER root

ENV TRINO_PLUGIN_VERSION=2.4.0
ENV RANGER_VERSION=ranger-2.4.0-trino-plugin
ENV TAR_FILE=/root/${RANGER_VERSION}.tar.gz

COPY install.properties /root/install.properties

RUN mkdir -p /home/ranger/dist

RUN chown -R "root:root" /data/trino && \
    chown -R "root:root" /usr/bin/trino && \
    chown -R "root:root" /usr/lib/trino && \
    chown -R "root:root" /etc/trino

# Install necessary utilities
RUN microdnf install gzip -y && \
    microdnf install dos2unix -y && \
    microdnf install findutils -y

RUN echo $TRINO_PLUGIN_VERSION >> /home/ranger/dist/version

RUN curl -k https://github.com/gympass/apache-ranger/releases/download/plugin-trino-452/${RANGER_VERSION}.tar.gz --output ${RANGER_VERSION}.tar.gz -L && \
    mkdir -p /root/${RANGER_VERSION} && \
    tar xvf ${RANGER_VERSION}.tar.gz -C /root/${RANGER_VERSION} --strip-components 1 && \
    yes | cp -rf /root/install.properties /root/${RANGER_VERSION}/ && \
    find /root -type f -exec dos2unix {} \;


RUN chown "root:root" /root/${RANGER_VERSION}/*
# Add entrypoint script
COPY entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh && \
    chmod +x /root/${RANGER_VERSION}/enable-trino-plugin.sh
ENTRYPOINT ["/root/entrypoint.sh"]
