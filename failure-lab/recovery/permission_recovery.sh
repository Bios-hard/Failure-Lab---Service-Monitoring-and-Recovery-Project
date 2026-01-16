#!/bin/bash

source /opt/failure-lab/log.sh

FILE="/opt/failure-lab/data/service.state"

log_event WARNING PERMISSION "Starting permission recovery"

chmod 644 "$FILE"
chown root:root "$FILE"

systemctl restart dummy-service.service

log_event INFO PERMISSION "Permission recovery completed"
