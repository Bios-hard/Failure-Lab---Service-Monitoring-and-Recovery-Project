# Failure Lab – Dummy Service Monitoring and Recovery (Para Desenvolvedores)

## Sumário
1. [Objetivo do Projeto](#objetivo-do-projeto)  
2. [Estrutura de Diretórios](#estrutura-de-diretórios)  
3. [Descrição dos Scripts](#descrição-dos-scripts)  
4. [Systemd Service e Timer](#systemd-service-e-timer)  
5. [Exemplos de Logs](#exemplos-de-logs)  
6. [Comandos Importantes](#comandos-importantes)  
7. [Execução e Testes](#execução-e-testes)  

---

## Objetivo do Projeto
O **Failure Lab** é um laboratório de testes para monitoramento e recuperação automática de serviços no Linux.  
Ele realiza:
- Monitoramento de um serviço específico (`dummy-service.service`).  
- Registro de incidentes em logs (`/opt/failure-lab/logs/incidents.log`).  
- Verificação de permissões de arquivos críticos.  
- Recuperação de disco em casos de teste com arquivos temporários (`fill.img`).  
- Reinício automático do serviço quando ele falha.

Este README destina-se a desenvolvedores que irão:  
- Modificar os scripts de monitoramento e recuperação.  
- Ajustar os timers e serviços systemd.  
- Entender o fluxo completo de logs e incidentes.  

---

## Estrutura de Diretórios

```text
/opt/failure-lab/
├─ injector/                 # Scripts para injeção de falhas
│  └─ service-test/
│     └─ dummy_service.sh    # Serviço de teste simulado
├─ monitor/
│  └─ service_monitor.sh     # Script de monitoramento de serviço
├─ recovery/
│  └─ service_recovery.sh    # Script de recuperação de serviço
├─ data/
│  └─ service.state          # Estado do serviço monitorado (timestamps)
├─ logs/
│  └─ incidents.log          # Registro de incidentes e eventos
├─ dummy-service.service     # Arquivo systemd para o serviço de teste
├─ failure-service-monitor.service  # Serviço systemd do monitor
└─ failure-service-monitor.timer    # Timer systemd do monitor
```

---

## Descrição dos Scripts

### 1. `dummy_service.sh`
Script que simula um serviço. Estrutura básica:

```bash
#!/bin/bash
while true; do
    echo "$(date +'%Y-%m-%d %H:%M:%S') - Dummy service running"
    sleep 5
done
```

- Funciona como serviço systemd (`dummy-service.service`).  
- Simula execução contínua para testes de monitoramento.  

---

### 2. `service_monitor.sh`
Script responsável por monitorar o serviço e gerar logs. Exemplo:

```bash
#!/bin/bash
SERVICE="dummy-service.service"
LOG_FILE="/opt/failure-lab/logs/incidents.log"

# Verifica se o serviço está ativo
if systemctl is-active --quiet $SERVICE; then
    echo "$(date -u +'%Y-%m-%dT%H:%M:%SZ') | INFO | SERVICE | Service $SERVICE healthy" >> $LOG_FILE
else
    echo "$(date -u +'%Y-%m-%dT%H:%M:%SZ') | WARNING | SERVICE | Service $SERVICE down, starting recovery" >> $LOG_FILE
    /opt/failure-lab/recovery/service_recovery.sh
fi
```

- Detecta falhas do serviço.  
- Chama o script de recuperação quando necessário.  
- Registra logs no formato padronizado: `TIMESTAMP | LEVEL | COMPONENT | MESSAGE`.

---

### 3. `service_recovery.sh`
Script de recuperação do serviço e do ambiente:

```bash
#!/bin/bash
SERVICE="dummy-service.service"
LOG_FILE="/opt/failure-lab/logs/incidents.log"

# Reinicia o serviço
systemctl restart $SERVICE
echo "$(date -u +'%Y-%m-%dT%H:%M:%SZ') | INFO | SERVICE | Dummy service started (PID $(systemctl show $SERVICE -p MainPID --value))" >> $LOG_FILE

# Recupera disco de teste
DISK_TEST="/opt/failure-lab/injector/fill.img"
if [ -f "$DISK_TEST" ]; then
    rm $DISK_TEST
    echo "$(date -u +'%Y-%m-%dT%H:%M:%SZ') | INFO | DISK | Removed fill.img from disk-test" >> $LOG_FILE
fi
```

- Reinicia automaticamente o serviço monitorado.  
- Limpa arquivos de teste de disco (`fill.img`).  
- Atualiza logs de recuperação.

---

## Systemd Service e Timer

### `dummy-service.service`
```ini
[Unit]
Description=Failure Lab - Dummy Service
After=network.target

[Service]
ExecStart=/opt/failure-lab/injector/service-test/dummy_service.sh
Restart=always
RestartSec=3
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

### `failure-service-monitor.service`
```ini
[Unit]
Description=Failure Lab - Service Monitor

[Service]
Type=oneshot
ExecStart=/opt/failure-lab/monitor/service_monitor.sh
```

### `failure-service-monitor.timer`
```ini
[Unit]
Description=Failure Lab - Service Monitor Timer

[Timer]
OnBootSec=1min
OnUnitActiveSec=5s
AccuracySec=1s

[Install]
WantedBy=timers.target
```

- Timer executa o monitor a cada 5 segundos após inicialização do sistema.  
- Permite monitoramento contínuo sem intervenção manual.

---

## Exemplos de Logs

Formato padronizado:
```text
2026-01-14T00:50:16Z | INFO | SERVICE | Service dummy-service.service healthy
2026-01-14T00:50:16Z | WARNING | DISK | Starting disk recovery procedure
2026-01-14T00:50:16Z | INFO | DISK | Removed fill.img from disk-test
2026-01-14T00:50:16Z | INFO | DISK | Disk recovery procedure completed
```

- `INFO` → Informações gerais.  
- `WARNING` → Indica falhas ou procedimentos de recuperação.  
- Componentes: `SERVICE`, `DISK`, `PERMISSION`.  

---

## Comandos Importantes

- Checar status do serviço:
```bash
systemctl status dummy-service.service
```

- Listar timers ativos:
```bash
systemctl list-timers --all | grep failure-service
```

- Reiniciar serviço manualmente:
```bash
sudo systemctl restart dummy-service.service
```

- Obter PID do serviço:
```bash
systemctl show dummy-service.service -p MainPID --value
```

- Monitorar logs:
```bash
tail -f /opt/failure-lab/logs/incidents.log
```

---

## Execução e Testes

1. Conceder permissão de execução aos scripts:
```bash
sudo chmod +x /opt/failure-lab/monitor/service_monitor.sh
sudo chmod +x /opt/failure-lab/recovery/service_recovery.sh
```

2. Habilitar e iniciar o serviço e o timer:
```bash
sudo systemctl daemon-reload
sudo systemctl enable --now dummy-service.service
sudo systemctl enable --now failure-service-monitor.timer
```

3. Simular falha do serviço:
```bash
sudo kill -9 $(systemctl show dummy-service.service -p MainPID --value)
```
O monitor detecta a falha e reinicia o serviço automaticamente.

