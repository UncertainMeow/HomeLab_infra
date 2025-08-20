# HomeLab Deployment Guide

## DNS + GitLab Stack Deployment

This guide walks through deploying both the DNS server and GitLab stack using Ansible.

### Prerequisites

1. **SSH Access**: 1Password SSH agent configured and working
2. **Ansible**: Version 2.14+ installed
3. **Target Hosts**: rseau (DNS) and rawls (GitLab) accessible via SSH
4. **Secrets**: Tailscale auth key and secure passwords ready

### Phase 1: Deploy DNS Server

Deploy Technitium DNS container on rseau at 10.203.1.3:

```bash
cd ansible-infrastructure

# Deploy DNS server
ansible-playbook playbooks/deployment/technitium-dns-container.yml

# Verify DNS deployment
ansible rseau -m uri -a "url=http://10.203.1.2:5380 method=GET"
```

**Post-DNS Setup**:
1. Access DNS admin: http://10.203.1.2:5380
2. Login with credentials from playbook output
3. Configure your router to use 10.203.1.3 as primary DNS

### Phase 2: Deploy GitLab Stack

Deploy comprehensive GitLab stack with Caddy and Tailscale on rawls:

```bash
# Test connectivity first
ansible rawls -m ping

# Deploy GitLab stack (Phase 1: GitLab + Caddy only)
ansible-playbook playbooks/deployment/gitlab-stack.yml

# Watch deployment progress
ansible-playbook playbooks/deployment/gitlab-stack.yml -v
```

### Deployment Configuration

Key variables (customize as needed):

```yaml
# In playbooks/deployment/gitlab-stack.yml
gitlab_external_url: "https://gitlab.doofus.co"
enable_tailscale_domains: true
tailscale_hostname: "rawls"
enable_semaphore: false  # Phase 1
enable_kestra: false     # Phase 1
```

### Post-Deployment

After successful deployment:

1. **Access GitLab**:
   - External: https://gitlab.doofus.co
   - Tailscale: https://gitlab.rawls.ts.net
   - Local: http://10.203.3.47

2. **Initial Login**:
   - Username: `root`
   - Password: (check deployment output or `/opt/gitlab-deployment-info.txt`)

3. **Verify Services**:
   ```bash
   # Check all containers
   ssh ansible@10.203.3.47
   cd /opt/gitlab-stack
   docker compose ps
   
   # Check logs
   docker compose logs -f gitlab
   docker compose logs -f caddy
   ```

4. **Configure DNS Records**:
   - In your DNS admin (10.203.1.2:5380)
   - Add: gitlab.doofus.co → 10.203.3.47
   - Add: rawls.doofus.co → 10.203.3.47

### Phase Expansion

#### Phase 2: Add Semaphore
```bash
# Edit playbook and set:
enable_semaphore: true

# Redeploy
ansible-playbook playbooks/deployment/gitlab-stack.yml
```

#### Phase 3: Add Kestra  
```bash
# Edit playbook and set:
enable_kestra: true

# Redeploy  
ansible-playbook playbooks/deployment/gitlab-stack.yml
```

### Troubleshooting

#### DNS Issues
```bash
# Check DNS container status
ansible rseau -m command -a "docker ps"
ansible rseau -m command -a "docker logs technitium-dns"

# Test DNS resolution
nslookup gitlab.doofus.co 10.203.1.3
```

#### GitLab Issues
```bash
# Check GitLab health
ansible rawls -m uri -a "url=http://10.203.3.47/health_check method=GET"

# GitLab logs
ssh ansible@10.203.3.47
cd /opt/gitlab-stack
docker compose logs gitlab

# Restart services if needed
docker compose restart
```

#### Caddy Issues
```bash
# Check Caddy config
ssh ansible@10.203.3.47
cd /opt/gitlab-stack
docker compose exec caddy caddy validate --config /etc/caddy/Caddyfile

# Caddy logs
docker compose logs caddy
```

#### Tailscale Issues  
```bash
# Check Tailscale status
ssh ansible@10.203.3.47
sudo tailscale status
sudo tailscale netcheck

# Re-authenticate if needed
sudo tailscale up --auth-key=YOUR_AUTH_KEY --hostname=rawls
```

### Security Notes

- UFW firewall configured on both hosts
- fail2ban protection enabled
- Docker security profiles applied  
- All services behind Caddy reverse proxy
- SSH keys only (no password auth)

### Backup Information

- **GitLab Backups**: Automated daily at 2 AM
- **Backup Location**: `/opt/gitlab-backups/`
- **Retention**: 7 days (configurable)
- **Manual Backup**: `/opt/backup-scripts/gitlab-backup.sh`

### Next Steps

1. **Create First Project**: Login to GitLab and create repository
2. **Configure CI/CD**: Set up GitLab runners for automation
3. **DNS Propagation**: Update external DNS if needed
4. **Monitoring**: Consider adding Prometheus/Grafana
5. **MS-01 Migration**: Plan cluster migration when new hardware arrives

### File Locations

- **DNS Config**: `/opt/technitium/` on rseau
- **GitLab Stack**: `/opt/gitlab-stack/` on rawls  
- **Deployment Info**: `/opt/gitlab-deployment-info.txt` on rawls
- **Backup Scripts**: `/opt/backup-scripts/` on rawls