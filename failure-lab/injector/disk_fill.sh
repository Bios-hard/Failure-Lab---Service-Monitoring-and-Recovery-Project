#!/bin/bash

source /opt/failure-lab/log.sh

TARGET_DIR="/opt/failure-lab/injector/disk-test"
FILL_FILE="${TARGET_DIR}/fill.img"
MAX_SIZE_MB=2048   # 2 GB — seguro para seu disco

log_event INFO DISK "Starting controlled disk fill (${MAX_SIZE_MB}MB)"

dd if=/dev/zero of="${FILL_FILE}" bs=1M count="${MAX_SIZE_MB}" status=progress

log_event WARNING DISK "Disk fill completed"
