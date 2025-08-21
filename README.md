# HomeLab Infrastructure Automation

A comprehensive Ansible-based infrastructure automation suite for managing a Proxmox homelab with AI/ML capabilities, featuring GitLab CE with Caddy reverse proxy, DNS management, and scalable CI/CD workflows.

## 🏆 What This Repository Delivers

This project provides a **production-ready homelab infrastructure** that successfully deploys:

- **GitLab CE** with Caddy reverse proxy and automatic HTTPS
- **Technitium DNS** server for internal domain management  
- **Tailscale integration** for secure remote access
- **Comprehensive security hardening** with UFW and fail2ban
- **Automated backup systems** for critical services
- **Scalable architecture** ready for container orchestration (k3s/Docker Swarm)

## 🚀 Quick Start

### Prerequisites

- **Proxmox VE** cluster with SSH access
- **1Password SSH Agent** configured (recommended)
- **Ansible 2.14+** installed locally
- **Domain** managed by Cloudflare (optional for external access)

### Rapid Deployment

```bash
# 1. Clone and navigate
git clone <repository-url>
cd HomeLab_infra/ansible-infrastructure

# 2. Configure inventory
cp inventory/hosts.yml.example inventory/hosts.yml
# Edit with your host IPs and credentials

# 3. Deploy DNS server
ansible-playbook playbooks/deployment/technitium-dns-container.yml

# 4. Deploy GitLab stack
ansible-playbook playbooks/deployment/gitlab-stack.yml

# 5. Access your services
# GitLab: https://gitlab.yourdomain.com
# DNS Admin: http://your-dns-host:5380
```

## 📊 Architecture Overview

### Current Infrastructure

```
┌─────────────────────────────────────────────────────┐
│ Production HomeLab Stack                            │
├─────────────────────────────────────────────────────┤
│ socrates    │ AI/ML workloads (OpenWebUI, Ollama)   │
│ rawls       │ GitLab CE + Caddy (IaC Services)      │
│ rseau       │ DNS Server (Technitium)               │  
│ htpc        │ Media services                        │
│ zinn        │ NAS/Storage                           │
└─────────────────────────────────────────────────────┘
```

### Service Architecture

```
Internet → Cloudflare → Tailscale → Caddy → [GitLab|Services]
Internal → DNS Server → Caddy → Services
```

### Data Flow

- **External Access**: `service.domain.com` → Cloudflare DNS → Tailscale → Caddy → Service
- **Internal Access**: `service.internal.domain` → Local DNS → Caddy → Service  
- **Backup Flow**: GitLab → Automated Backups → NAS Storage
- **CI/CD Flow**: Git Push → GitLab → Runners → Deploy

## 🛠️ Core Components

### Ansible Infrastructure

**Playbooks:**
- **`playbooks/deployment/gitlab-stack.yml`** - Complete GitLab CE deployment with Caddy
- **`playbooks/deployment/technitium-dns-container.yml`** - DNS server deployment
- **`playbooks/setup/initial-setup.yml`** - Server hardening and user management
- **`playbooks/maintenance/hardware-assessment.yml`** - AI/ML hardware analysis
- **`playbooks/deployment/docker-compose-nas.yml`** - Deploy Docker Compose NAS stack on htpc

**Roles:**
- **`roles/gitlab_stack/`** - Comprehensive GitLab + Caddy + Tailscale integration
- **`roles/technitium_dns/`** - DNS server management
- **`roles/common/`** - Base system configuration
- **`roles/ssh_hardening/`** - Security hardening

### GitLab Stack Features

- **GitLab CE** with full CI/CD capabilities
- **Caddy reverse proxy** with automatic HTTPS
- **Tailscale magic domains** for secure access
- **Automated backups** with retention policies
- **Security hardening** (UFW, fail2ban, SSH restrictions)
- **Performance optimization** for homelab resources

### DNS Management

- **Technitium DNS** server with web interface
- **Internal domain resolution** for homelab services
- **Dynamic zone management** via API
- **Integration with external DNS** providers

## 📋 Deployment Guide

### Infrastructure Groups

The inventory organizes hosts into logical groups:

- **`proxmox`** - Virtualization hosts (socrates, rawls, rseau)
- **`ai_workers`** - AI/ML workload hosts (socrates)  
- **`iac_services`** - Infrastructure services (rawls with GitLab)
- **`dns_servers`** - DNS infrastructure (rseau)
- **`monitoring`** - Future monitoring stack

### Variables and Configuration

**Global Variables** (`inventory/group_vars/all.yml`):
```yaml
ansible_user: ansible
ansible_python_interpreter: /usr/bin/python3
```

**GitLab Stack Variables** (`roles/gitlab_stack/defaults/main.yml`):
```yaml
gitlab_external_url: "https://gitlab.yourdomain.com"
enable_tailscale_domains: true
enable_automated_backups: true
```

### Security Configuration

**Automated Security Measures:**
- SSH hardening (disable root, key-only auth)
- UFW firewall with minimal required ports
- fail2ban for intrusion prevention  
- Docker security profiles
- Automated security updates

**Network Security:**
- Services behind reverse proxy
- TLS termination at Caddy
- Internal network segmentation
- VPN access via Tailscale

## 🔒 Security Features

### Enterprise-Grade Security

This project implements **bulletproof security practices**:

- **🔐 Ansible Vault**: All secrets encrypted with industry-standard encryption
- **🚫 Zero Hardcoded Passwords**: Dynamic secret generation with secure fallbacks
- **🔑 1Password SSH Agent**: Centralized SSH key management
- **🛡️ Multi-layer Security**: UFW, fail2ban, SSH hardening, and Docker security
- **📝 Security Documentation**: Comprehensive security guide at [SECRETS-MANAGEMENT.md](SECRETS-MANAGEMENT.md)

### Critical Security Implementation

**BEFORE (Insecure)**:
```yaml
gitlab_root_password: "GitLabAdmin123!"  # ❌ NEVER DO THIS
```

**AFTER (Production-Ready)**:
```yaml
gitlab_root_password: "{{ vault_gitlab_root_password | default(lookup('password', '/dev/null length=20 chars=ascii_letters,digits,punctuation')) }}"  # ✅ SECURE
```

> **🚨 SECURITY FIRST**: All default passwords have been eliminated and replaced with Ansible Vault patterns. See [SECRETS-MANAGEMENT.md](SECRETS-MANAGEMENT.md) for complete security implementation details.

## 🔧 Management Commands

### Service Management

```bash
# GitLab stack management
ansible-playbook playbooks/deployment/gitlab-stack.yml         # Deploy/update
ansible rawls -m command -a "cd /opt/gitlab-stack && docker-compose ps"  # Status
ansible rawls -m command -a "cd /opt/gitlab-stack && docker-compose logs -f gitlab"  # Logs

# DNS management  
ansible-playbook playbooks/deployment/technitium-dns-container.yml  # Deploy/update
ansible rseau -m uri -a "url=http://localhost:5380/api/health"      # Health check

# System maintenance
ansible-playbook playbooks/maintenance/system-update.yml           # Update systems
ansible-playbook playbooks/maintenance/hardware-assessment.yml     # Hardware analysis
```

### Backup and Recovery

```bash
# GitLab backups (automated daily)
ansible rawls -m command -a "cd /opt/gitlab-stack && docker-compose exec gitlab gitlab-backup create"

# Manual backup verification
ansible rawls -m command -a "ls -la /opt/gitlab-backups/"

# Backup cleanup (automated weekly)
ansible rawls -m command -a "/opt/backup-scripts/gitlab-cleanup.sh"
```

### Monitoring and Troubleshooting

```bash
# Health checks
ansible all -m ping                                    # Connectivity
ansible all -m command -a "systemctl status docker"   # Docker status
ansible all -m command -a "ufw status"                # Firewall status

# Performance monitoring
ansible all -m command -a "htop -n 1"                 # System resources
ansible rawls -m command -a "docker stats --no-stream"  # Container resources

# Log analysis
ansible rawls -m command -a "journalctl -u docker -f --no-pager"  # Docker logs
ansible all -m command -a "tail -n 50 /var/log/auth.log"          # Auth logs
```

## 🔮 Scaling and Future Expansion

### Phase 2: Advanced Services

The architecture supports easy expansion:

```yaml
# Enable Semaphore for Ansible UI
enable_semaphore: true

# Enable Kestra for workflow orchestration  
enable_kestra: true
```

### Phase 3: Container Orchestration

Ready for k3s/Docker Swarm migration:

- **Persistent volumes** already configured
- **Service discovery** patterns established
- **Load balancing** via Caddy
- **Secret management** frameworks in place

### Hardware Expansion

Architecture scales to support additional nodes:

```yaml
# Future MS-01 cluster nodes
ms01-01:
  ansible_host: 10.203.3.50
  role: k3s_master
  
ms01-02:
  ansible_host: 10.203.3.51  
  role: k3s_worker
```

## 📚 Documentation

- **[SECRETS-MANAGEMENT.md](SECRETS-MANAGEMENT.md)** - 🔒 **CRITICAL**: Security implementation and vault setup
- **[CLAUDE.md](CLAUDE.md)** - AI assistant context and operational knowledge  
- **[ansible-infrastructure/inventory/hosts.yml](ansible-infrastructure/inventory/hosts.yml)** - Infrastructure inventory configuration
- **Role Documentation** - Each role includes comprehensive defaults and templates
- **Playbook Comments** - Detailed inline documentation for all automation

## 🧪 Testing and Validation

### Validation Framework

```bash
# Full infrastructure validation
ansible-playbook tests/validate-setup.yml

# Individual component testing
ansible-playbook playbooks/setup/test-connectivity.yml
ansible all -m ping --one-line
```

### Continuous Validation

- **Health check endpoints** for all services
- **Automated backup verification** 
- **Service dependency validation**
- **Performance regression testing**

## 🤝 Contributing

### Development Workflow

1. **Fork** the repository
2. **Create feature branch** from main  
3. **Develop** with comprehensive testing
4. **Document** changes and additions
5. **Submit pull request** with detailed description

### Adding New Services

1. **Create role** in `roles/` directory
2. **Add playbook** in appropriate `playbooks/` subdirectory  
3. **Update inventory** with new host groups if needed
4. **Document** in README and deployment guide
5. **Test** on development environment

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Proxmox VE** for robust virtualization platform
- **GitLab** for comprehensive DevOps platform
- **Caddy** for elegant reverse proxy solution
- **Technitium DNS** for powerful DNS server
- **Tailscale** for secure networking
- **Ansible** for infrastructure automation excellence

---

## 📊 Project Statistics

- **Playbooks**: 15+ production-ready automation scripts
- **Roles**: 8 comprehensive service roles
- **Templates**: 20+ configuration templates  
- **Security**: Multi-layer security hardening
- **Documentation**: Comprehensive guides and examples
- **Testing**: Validation framework for all components

**Built with ❤️ for homelab enthusiasts and infrastructure automation**
