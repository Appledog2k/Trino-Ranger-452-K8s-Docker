#!/bin/bash

sleep 30
# sudo -i
/root/${RANGER_VERSION}/enable-trino-plugin.sh && \
/usr/lib/trino/bin/run-trino
