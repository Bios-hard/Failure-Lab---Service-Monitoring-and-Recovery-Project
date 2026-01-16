# Failure Lab - Service Monitoring and Recovery Project

## Overview

Failure Lab is a Linux-based laboratory project designed to **simulate system failures and automatically monitor and recover services**. The project provides a controlled environment for testing service reliability, disk usage, and file permissions, allowing developers and administrators to experiment safely without risking production systems.

The core concept is to **automate detection and recovery of failures** while logging all events for detailed analysis.

## Project Objectives

- **Automate monitoring** of Linux services, permissions, and disk usage.
- **Log every event** with timestamps, incident type, and context.
- **Simulate controlled failures**, including stopping services, modifying permissions, and filling disk space.
- **Automatically recover** from detected issues by restarting services, fixing permissions, or cleaning up disk space.
- **Provide an educational platform** to learn about system reliability and Linux administration.

## Architecture and Implementation

### Systemd Services and Timers

The project uses **systemd** to schedule and run scripts automatically:

- **Dummy Service** (`dummy-service.service`): A test service that can be intentionally stopped to simulate failure.
- **Monitoring Service** (`failure-service-monitor.service`) with Timer (`failure-service-monitor.timer`): Periodically runs monitoring scripts to check the health of services, permissions, and disk.

Example of a systemd service configuration:
```ini
[Unit]
Description=Dummy Service

[Service]
ExecStart=/opt/failure-lab/injector/service-test/dummy_service.sh
Restart=always
```

### Bash Scripts

1. **Service Monitoring (`service_monitor.sh`)**
   - Checks whether a service is running.
   - Restarts stopped services and logs the event.

2. **Recovery Script (`service_recovery.sh`)**
   - Executes corrective actions for failed services, incorrect permissions, or disk issues.
   - Updates logs accordingly.

Example snippet from the monitoring script:
```bash
#!/bin/bash
SERVICE="dummy-service.service"
if systemctl is-active --quiet $SERVICE; then
    echo "$(date -u) | INFO | SERVICE | Service $SERVICE healthy" >> /opt/failure-lab/logs/incidents.log
else
    echo "$(date -u) | WARNING | SERVICE | Service $SERVICE not running" >> /opt/failure-lab/logs/incidents.log
    systemctl restart $SERVICE
fi
```

### Logging

All events are logged with **UTC timestamps**, incident type (`INFO`, `WARNING`), and context (`SERVICE`, `DISK`, `PERMISSION`):
```
2026-01-14T00:46:56Z | INFO | SERVICE | Service dummy-service.service healthy
2026-01-14T00:46:56Z | WARNING | DISK | Starting disk recovery procedure
2026-01-14T00:46:56Z | INFO | DISK | Removed fill.img from disk-test
```

### File Structure

```
/opt/failure-lab/
├─ injector/service-test/dummy_service.sh
├─ monitor/service_monitor.sh
├─ recovery/service_recovery.sh
├─ logs/incidents.log
└─ data/service.state
```

## Skills and Knowledge Required

To fully understand or replicate this project, you need:

### Linux and Systemd
- Creating `.service` and `.timer` files.
- Managing services: `systemctl start/stop/status/enable/daemon-reload`.
- Process management: `ps`, `kill`, `journalctl`.

### Bash Scripting
- Conditional statements (`if`, `case`) and loops (`for`, `while`).
- File operations: `echo`, `cat`, `tail`, `chmod`.
- Output redirection (`>>`) and command substitution (`$(...)`).

### Logging and Monitoring
- Structuring logs with timestamps and incident categorization.
- Reading systemd logs with `journalctl`.

### Automated Recovery
- Restarting services automatically.
- Correcting file permissions with `chmod`.
- Cleaning or simulating disk usage for tests.

### Testing Failures Safely
- Simulating failures without affecting production systems.
- Using dummy scripts and temporary files for experiments.

## Usage and Examples

**Check service status:**
```bash
systemctl status dummy-service.service
```

**Kill the dummy service (simulates failure):**
```bash
sudo kill -9 $(systemctl show dummy-service.service -p MainPID --value)
```

**Run the monitor manually:**
```bash
sudo /opt/failure-lab/monitor/service_monitor.sh
```

**View recent logs:**
```bash
tail -n 10 /opt/failure-lab/logs/incidents.log
```

This project serves as both a **learning platform** and a **robust framework** for automated Linux service monitoring and recovery.

