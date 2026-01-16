#!/bin/bash

source /opt/failure-lab/log.sh

SERVICE="dummy-service.service"

if ! systemctl is-active --quiet "$SERVICE"; then
    log_event CRITICAL SERVICE "Service $SERVICE is NOT active"
    /opt/failure-lab/recovery/service_recovery.sh
else
    log_event INFO SERVICE "Service $SERVICE healthy"
fi
