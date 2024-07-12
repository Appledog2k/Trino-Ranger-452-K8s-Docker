#!/bin/bash

/root/${RANGER_VERSION}/enable-trino-plugin.sh && \
/usr/lib/trino/bin/run-trino
