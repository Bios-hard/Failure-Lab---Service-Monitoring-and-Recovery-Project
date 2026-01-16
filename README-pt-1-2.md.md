# Failure Lab – Sistema de Monitoramento e Recuperação de Serviços (Desenvolvedor)

## Visão Geral
O **Failure Lab** é um ambiente de testes voltado para monitoramento contínuo de serviços, permissões e integridade de disco em sistemas Linux. Ele consiste em scripts que:

- Monitoram serviços críticos.
- Verificam permissões de arquivos importantes.
- Executam procedimentos de recuperação de disco.
- Registram logs detalhados de incidentes.

O sistema é projetado para ser **extensível**, permitindo incluir novos serviços e mecanismos de recuperação conforme a necessidade do laboratório.

---

## Estrutura de Diretórios

```
/opt/failure-lab/
├─ injector/                 # Scripts que simulam falhas ou serviços de teste
│  └─ service-test/
│     └─ dummy_service.sh    # Serviço de teste
├─ monitor/                  # Scripts de monitoramento
│  └─ service_monitor.sh     # Verifica serviços, permissões e disco
├─ recovery/                 # Scripts de recuperação
│  └─ service_recovery.sh    # Executa ações corretivas
├─ logs/                     # Logs de incidentes
│  └─ incidents.log
├─ data/
│  └─ service.state          # Histórico de monitoramento
└─ systemd/                  # Arquivos de serviço e timer
   ├─ dummy-service.service
   ├─ failure-service-monitor.service
   └─ failure-service-monitor.timer
```

---

## Scripts Principais

### 1. `service_monitor.sh`
Função:
- Verifica se serviços configurados estão ativos.
- Confere permissões de arquivos críticos.
- Checa integridade e uso do disco.
- Aciona scripts de recuperação quando necessário.
- Registra todas as ações em `/opt/failure-lab/logs/incidents.log`.

Exemplo simplificado:

```bash
#!/bin/bash
SERVICE="dummy-service.service"

# Verifica status do serviço
if systemctl is-active --quiet $SERVICE; then
    echo "$(date -u) | INFO | SERVICE | Service $SERVICE healthy" >> /opt/failure-lab/logs/incidents.log
else
    echo "$(date -u) | WARNING | SERVICE | Service $SERVICE failed, starting recovery" >> /opt/failure-lab/logs/incidents.log
    /opt/failure-lab/recovery/service_recovery.sh $SERVICE
fi
```

### 2. `service_recovery.sh`
Função:
- Executa ações corretivas caso um serviço esteja inativo ou permissões estejam incorretas.
- Reinicia serviços problemáticos.
- Ajusta permissões de arquivos.
- Pode incluir recuperação de disco.

Exemplo:

```bash
#!/bin/bash
SERVICE=$1

# Reinicia serviço
systemctl restart $SERVICE
echo "$(date -u) | INFO | SERVICE | Dummy service started (PID $(systemctl show $SERVICE -p MainPID --value))" >> /opt/failure-lab/logs/incidents.log

# Ajusta permissões padrão
chmod 644 /opt/failure-lab/data/service.state
echo "$(date -u) | INFO | PERMISSION | Permissions OK (644)" >> /opt/failure-lab/logs/incidents.log
```

### 3. Dummy Service (`dummy_service.sh`)
- Serviço simulado para teste do monitoramento.
- Apenas faz `sleep 5` continuamente.
- Permite simular falhas matando o PID e verificar se o monitor reinicia automaticamente.

```bash
#!/bin/bash
while true; do
    sleep 5
done
```

---

## Configuração do Systemd

### 1. Serviço de teste
`/etc/systemd/system/dummy-service.service`:

```ini
[Unit]
Description=Failure Lab - Dummy Service
After=network.target

[Service]
ExecStart=/bin/bash /opt/failure-lab/injector/service-test/dummy_service.sh
Restart=always
RestartSec=3s

[Install]
WantedBy=multi-user.target
```

### 2. Serviço do monitor
`/etc/systemd/system/failure-service-monitor.service`:

```ini
[Unit]
Description=Failure Lab - Service Monitor

[Service]
Type=oneshot
ExecStart=/opt/failure-lab/monitor/service_monitor.sh
```

### 3. Timer do monitor
`/etc/systemd/system/failure-service-monitor.timer`:

```ini
[Unit]
Description=Failure Lab - Service Monitor Timer

[Timer]
OnBootSec=1min
OnUnitActiveSec=30s
Unit=failure-service-monitor.service

[Install]
WantedBy=timers.target
```

- O timer dispara o monitor a cada 30 segundos.
- O monitor verifica serviços, permissões e disco.

---

## Logs e Histórico

- `/opt/failure-lab/logs/incidents.log` registra:
  - STATUS dos serviços (`healthy`, `failed`).
  - PERMISSIONS (`644`, `corrigido`).
  - DISK (`usage normal`, `recovery executed`).

Exemplo de log:

```
2026-01-14T00:50:16Z | INFO | SERVICE | Service dummy-service.service healthy
2026-01-14T00:50:16Z | WARNING | DISK | Starting disk recovery procedure
2026-01-14T00:50:16Z | INFO | DISK | Removed fill.img from disk-test
2026-01-14T00:50:16Z | INFO | DISK | Disk recovery procedure completed
```

- `/opt/failure-lab/data/service.state` mantém timestamps do monitoramento.

---

## Comandos Úteis

```bash
# Verificar status do serviço
systemctl status dummy-service.service

# Reiniciar serviço manualmente
sudo systemctl restart dummy-service.service

# Monitorar logs do serviço
journalctl -u dummy-service.service --no-pager

# Iniciar timer de monitoramento
sudo systemctl enable --now failure-service-monitor.timer

# Listar timers ativos
systemctl list-timers --all | grep failure-service

# Matar PID do serviço (simulando falha)
sudo kill -9 $(systemctl show dummy-service.service -p MainPID --value)
```

---

## Observações para Desenvolvimento

1. **Extensibilidade:** Adicione novos serviços editando `service_monitor.sh` e `service_recovery.sh`.
2. **Logs detalhados:** Todo evento é registrado com timestamp UTC e tipo (`INFO`, `WARNING`).
3. **Testes:** O `dummy-service` permite simular falhas frequentes para testar o monitoramento.
4. **Recuperação de disco:** Scripts podem ser adaptados para recuperar arquivos críticos ou remover imagens de teste.

