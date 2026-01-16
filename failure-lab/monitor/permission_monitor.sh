#!/bin/bash

source /opt/failure-lab/log.sh

FILE="/opt/failure-lab/data/service.state"
EXPECTED_PERM="644"

CURRENT_PERM=$(stat -c "%a" "$FILE")

if [ "$CURRENT_PERM" != "$EXPECTED_PERM" ]; then
    log_event CRITICAL PERMISSION "Invalid permissions on service.state ($CURRENT_PERM)"
    /opt/failure-lab/recovery/permission_recovery.sh
else
    log_event INFO PERMISSION "Permissions OK ($CURRENT_PERM)"
fi

