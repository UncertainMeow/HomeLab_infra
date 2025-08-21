# IaC Services VM Deployment

Deploys a comprehensive Infrastructure as Code services VM on rawls with phased rollout:
- **Phase 1**: GitLab CE + Caddy reverse proxy
- **Phase 2**: Add Semaphore for Ansible/Terraform UI  
- **Phase 3**: Add Kestra for workflow orchestration

## Features

- **Dual Access**: Both `service.doofus.co` and `service.rawls.ts.net` domains
- **Automatic HTTPS**: Caddy handles SSL certificates via Tailscale magic domains
- **Phased Deployment**: Start with GitLab, add services incrementally
- **CI/CD Ready**: GitLab runners for homelab automation
- **Scalable**: Ready for MS-01 cluster migration

## Prerequisites

1. **Proxmox Access**: API access to rawls (10.203.3.47)
2. **Cloudflare API**: Token with DNS edit permissions for doofus.co
3. **Tailscale**: Auth key for joining tailnet
4. **SSH Keys**: Public key from 1Password (`ssh-add -L`)

## Quick Start

### 1. Configure Variables

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### 2. Upload Cloud-Init Template

The Proxmox cloud-init snippet needs to be uploaded to rawls:

```bash
# Copy cloud-init file to rawls Proxmox snippets directory
scp cloud-init/iac-services-cloud-init.yml root@10.203.3.47:/var/lib/vz/snippets/
```

### 3. Deploy Infrastructure

```bash
terraform init
terraform plan
terraform apply
```

### 4. Access Services

**Phase 1 (Immediate)**:
- GitLab External: https://gitlab.doofus.co
- GitLab Tailscale: https://gitlab.rawls.ts.net
- SSH: `ssh iac@10.203.3.60`

## Service Access

### GitLab
- **External**: https://gitlab.doofus.co
- **Tailscale**: https://gitlab.rawls.ts.net
- **SSH Git**: `git clone git@gitlab.doofus.co:2222/user/repo.git`
- **Initial Login**: root / (password from terraform.tfvars)

### Phase 2: Semaphore (Future)
- **External**: https://semaphore.doofus.co
- **Tailscale**: https://semaphore.rawls.ts.net
- **Purpose**: Ansible playbook UI and Terraform management

### Phase 3: Kestra (Future)
- **External**: https://kestra.doofus.co  
- **Tailscale**: https://kestra.rawls.ts.net
- **Purpose**: Workflow orchestration and data pipelines

## Phase Rollout Instructions

### Phase 1: GitLab Only ✅
Services automatically start after deployment.

### Phase 2: Add Semaphore
1. SSH to VM: `ssh iac@10.203.3.60`
2. Edit `/home/iac/.env` - uncomment Semaphore variables
3. Edit `/home/iac/docker-compose.yml` - uncomment semaphore service
4. Edit `/home/iac/Caddyfile` - uncomment Semaphore domains
5. Restart services: `docker compose up -d`

### Phase 3: Add Kestra  
1. SSH to VM: `ssh iac@10.203.3.60`
2. Edit `/home/iac/.env` - uncomment Kestra variables
3. Edit `/home/iac/docker-compose.yml` - uncomment kestra and postgres services
4. Edit `/home/iac/Caddyfile` - uncomment Kestra domains
5. Restart services: `docker compose up -d`

## Architecture

```
Internet → Cloudflare → Tailscale → Caddy → [GitLab|Semaphore|Kestra]
Tailnet → Tailscale Magic DNS → Caddy → [Services]
```

### Resource Allocation
- **VM**: 8 cores, 16GB RAM, 120GB disk
- **GitLab**: ~8GB RAM, 4 cores
- **Semaphore**: ~2GB RAM, 1 core  
- **Kestra**: ~4GB RAM, 2 cores
- **Buffer**: 2GB RAM, 1 core

## Migration to MS-01 Cluster

When your MS-01s arrive:
1. Export GitLab data: `docker exec gitlab gitlab-backup create`
2. Deploy services to k3s cluster on MS-01s
3. Import GitLab data to new deployment
4. Update DNS to point to cluster
5. Repurpose rawls VM for other services

## Troubleshooting

### Check Service Status
```bash
ssh iac@10.203.3.60
docker compose logs -f
docker compose ps
```

### Check Tailscale Status
```bash
sudo tailscale status
sudo tailscale netcheck
```

### Check Caddy Configuration
```bash
docker compose exec caddy caddy validate --config /etc/caddy/Caddyfile
docker compose logs caddy
```

### GitLab Issues
```bash
docker compose exec gitlab gitlab-ctl status
docker compose exec gitlab gitlab-ctl reconfigure
```

## Security Notes

- All services behind Caddy reverse proxy
- UFW firewall configured for minimal access
- Fail2ban protection enabled
- Tailscale provides secure external access
- SSH keys only (no password auth)

## Backup Strategy

- GitLab data: `/var/opt/gitlab` mounted as Docker volume
- Configuration: `/etc/gitlab` mounted as Docker volume  
- Regular GitLab backups: Built-in backup system
- VM snapshots: Proxmox snapshot capability