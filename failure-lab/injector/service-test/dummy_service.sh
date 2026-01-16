#!/bin/bash

source /opt/failure-lab/log.sh

STATE_FILE="/opt/failure-lab/data/service.state"

log_event INFO SERVICE "Dummy service started (PID $$)"

while true; do
    date +"%F %T" >> "$STATE_FILE"
    sleep 5
done

