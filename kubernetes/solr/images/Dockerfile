ARG SOLR_VERSION=8.11.2
FROM solr:${SOLR_VERSION}

# Copy audit config set
USER 0
RUN  mkdir -p /opt/solr/server/solr/configsets/ranger_audits/conf
COPY config/solr-ranger_audits/* /opt/solr/server/solr/configsets/ranger_audits/conf/
RUN chown -R solr:solr /opt/solr/server/solr/configsets/ranger_audits/

USER solr