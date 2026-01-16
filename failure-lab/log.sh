#!/bin/bash

LOG_FILE="/opt/failure-lab/logs/incidents.log"

log_event() {
    local severity="$1"
    local component="$2"
    local message="$3"

    local timestamp
    timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

    local line="${timestamp} | ${severity} | ${component} | ${message}"

    echo "${line}" >> "${LOG_FILE}"
    logger -t failure-lab "${line}"
}
