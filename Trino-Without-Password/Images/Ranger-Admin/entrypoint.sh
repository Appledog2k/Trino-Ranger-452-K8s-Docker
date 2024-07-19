#!/bin/bash

RANGER_VERSION=2.4.0

cd /root/ranger-${RANGER_VERSION}-admin/ && \
./setup.sh && \
ranger-admin start && \

python -m venv /root/ranger-admin/.env && source /root/ranger-admin/.env/bin/activate && pip install -r /root/ranger-admin/requirement.txt
python /root/ranger-admin/trino_service_setup.py && \
tail -f /root/ranger-${RANGER_VERSION}-admin/ews/logs/ranger-admin-*-.log
