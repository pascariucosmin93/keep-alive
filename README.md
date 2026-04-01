# keep-alive

Portable shell toolkit for synchronizing `keepalived` role changes with `iptables` NAT rules.

The project is designed for homelab or small HA router setups where:

- one node owns a VIP through `keepalived`
- both nodes must keep the same NAT rules
- `iptables` rules must be persisted after each update

## Layout

- `install.sh` installs the toolkit files into standard system paths
- `scripts/install-keepalived.sh` installs `keepalived` and `iptables-persistent`
- `scripts/backup-iptables.sh` creates a timestamped backup of current rules
- `scripts/apply-nat-mappings.sh` applies a clean NAT configuration from a mapping file
- `scripts/set-iptables-vip.sh` applies VIP-to-backend mappings and persists them
- `scripts/set-keepalived-role.sh` updates `state` and `priority` in `keepalived.conf`
- `scripts/show-ha-status.sh` prints VIP, keepalived and NAT state
- `examples/nat-mappings.conf.example` shows the mapping format without exposing real IPs
- `examples/keepalived.conf.example` shows a public-safe `keepalived` layout

## What the toolkit does

- backs up current `iptables` state
- removes stale NAT and filter rules
- applies the desired VIP-to-backend mappings
- persists rules with `iptables-save`
- helps set `MASTER` / `BACKUP` role and priority consistently

## Example Usage

```bash
chmod +x scripts/*.sh
sudo ./install.sh
sudo ./scripts/backup-iptables.sh
sudo ./scripts/set-iptables-vip.sh ./examples/nat-mappings.conf.example
sudo ./scripts/set-keepalived-role.sh /etc/keepalived/keepalived.conf MASTER 110
sudo ./scripts/show-ha-status.sh
```

## Installation

Install the operating system packages:

```bash
chmod +x scripts/*.sh
sudo ./scripts/install-keepalived.sh
```

Install the toolkit files:

```bash
chmod +x install.sh scripts/*.sh
sudo ./install.sh
```

The installer copies:

- scripts to `/usr/local/sbin`
- example mapping file to `/etc/keepalived/nat-mappings.conf.example`
- example keepalived config to `/etc/keepalived/keepalived.conf.example`

Enable and start keepalived:

```bash
sudo systemctl enable --now keepalived
sudo systemctl status keepalived --no-pager -l
```

## Keepalived hook example

```bash
notify_master "/usr/local/sbin/set-iptables-vip.sh /etc/keepalived/nat-mappings.conf"
notify_backup "/usr/local/sbin/set-iptables-vip.sh /etc/keepalived/nat-mappings.conf"
notify_fault  "/usr/local/sbin/set-iptables-vip.sh /etc/keepalived/nat-mappings.conf"
```

## Mapping model

Each entry uses:

```text
public_ip public_port backend_ip backend_port protocol
```

Example:

```text
VIP_ADDRESS 8080 APP_LB_IP 80 tcp
```

Replace placeholders with your own private values outside the public repo.
