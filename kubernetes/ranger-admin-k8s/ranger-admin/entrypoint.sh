#!/bin/bash

# Wait for PostgreSQL becomes available
sleep 30

# Set version
RANGER_VERSION=2.4.0

# Start Ranger Admin
cd /root/ranger-${RANGER_VERSION}-admin/ && \
./setup.sh && \
ranger-admin start && \

# Tail log
tail -f /root/ranger-${RANGER_VERSION}-admin/ews/logs/ranger-admin-*-.log
