FROM trinodb/trino:452

USER root

# Env
ENV RANGER_VERSION=ranger-2.4.0-trino-plugin
ENV TAR_FILE=/root/${RANGER_VERSION}.tar.gz

COPY install.properties /root/install.properties
COPY config.properties /etc/trino/config.properties
COPY password-authenticator.properties /etc/trino/password-authenticator.properties
COPY password.db /opt/security/password.db

# Install necessary utilities
RUN microdnf install gzip -y && \
    microdnf install dos2unix -y && \
    microdnf install findutils -y

RUN curl -k https://github.com/gympass/apache-ranger/releases/download/plugin-trino-452/${RANGER_VERSION}.tar.gz --output ${RANGER_VERSION}.tar.gz -L && \
    mkdir -p /root/${RANGER_VERSION} && \
    tar xvf ${RANGER_VERSION}.tar.gz -C /root/${RANGER_VERSION} --strip-components 1 && \
    yes | cp -rf /root/install.properties /root/${RANGER_VERSION}/ && \
    chown root:root -R /root/${RANGER_VERSION}/* && \
    find /root -type f -exec dos2unix {} \;

# Add entrypoint script
COPY entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh
ENTRYPOINT ["/root/entrypoint.sh"]