#!/bin/bash

source /opt/failure-lab/log.sh

THRESHOLD=90
MOUNT_POINT="/"

USAGE=$(df --output=pcent "$MOUNT_POINT" | tail -1 | tr -dc '0-9')

if [ "$USAGE" -ge "$THRESHOLD" ]; then
    log_event CRITICAL DISK "Disk usage at ${USAGE}% (threshold ${THRESHOLD}%)"
    exit 1
else
    log_event INFO DISK "Disk usage normal (${USAGE}%)"
    exit 0
fi
