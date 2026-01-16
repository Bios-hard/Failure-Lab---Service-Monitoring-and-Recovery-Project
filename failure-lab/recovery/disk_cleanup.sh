#!/bin/bash

source /opt/failure-lab/log.sh

TARGET_DIR="/opt/failure-lab/injector/disk-test"

log_event WARNING DISK "Starting disk recovery procedure"

if [ -d "$TARGET_DIR" ]; then
    rm -f "${TARGET_DIR}/fill.img"
    log_event INFO DISK "Removed fill.img from disk-test"
else
    log_event ERROR DISK "Target directory not found during recovery"
fi

log_event INFO DISK "Disk recovery procedure completed"
