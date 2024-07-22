#!/bin/bash

sleep 30
chmod -R 777 /etc/trino/jvm.config
/root/${RANGER_VERSION}/enable-trino-plugin.sh && \
/usr/lib/trino/bin/run-trino
