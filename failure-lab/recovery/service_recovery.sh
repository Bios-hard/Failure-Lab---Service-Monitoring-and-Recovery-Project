#!/bin/bash

source /opt/failure-lab/log.sh

SERVICE="dummy-service.service"

log_event WARNING SERVICE "Attempting service recovery"

systemctl restart "$SERVICE"
sleep 2

if systemctl is-active --quiet "$SERVICE"; then
    log_event INFO SERVICE "Service $SERVICE successfully recovered"
else
    log_event CRITICAL SERVICE "Service $SERVICE recovery FAILED"
fi
