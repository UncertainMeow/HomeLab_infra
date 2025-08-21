# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an Ansible-based infrastructure automation project for managing a Proxmox homelab with AI/ML capabilities. The project uses 1Password SSH Agent for secure key management and focuses on automating setup, maintenance, and deployment of AI workloads.

## Core Architecture

### Directory Structure
- **Root level**: Basic playbooks for quick operations (`gather-facts.yml`, `update-packages.yml`, `proxmox-maintenance.yml`, `setup-ansible-user.yml`)
- **ansible-infrastructure/**: Main collection with organized structure
  - `playbooks/`: Categorized playbooks (setup, maintenance, deployment, monitoring)
  - `roles/`: Custom roles (common, ssh_hardening, user_management, proxmox)
  - `inventory/`: Host and group configurations
  - `collections/`: Custom Ansible collection at `kellen.infrastructure`
  - `scripts/`: Utility scripts including `quick-setup.sh`
  - `tests/`: Validation and testing playbooks
  - `site.yml`: Master playbook orchestrating setup → maintenance → hardware assessment

### Key Configuration Files
- **ansible-infrastructure/inventory/hosts.yml**: Comprehensive inventory with groups (proxmox, ai_workers, dns_servers, monitoring)
- **ansible-infrastructure/site.yml**: Master orchestration playbook
- **ansible-infrastructure/scripts/quick-setup.sh**: Environment validation script

### Infrastructure Groups
- **proxmox**: Virtualization hosts (socrates, rseau) 
- **ai_workers**: AI/ML workload hosts (socrates with GPU support)
- **dns_servers**: DNS infrastructure (rseau running Technitium DNS)
- **kubernetes**: Future expansion for container orchestration
- **monitoring**: Prometheus/Grafana monitoring stack

## Essential Commands

### Prerequisites Check
```bash
# Run automated environment check (from ansible-infrastructure/)
./scripts/quick-setup.sh

# Verify 1Password SSH agent
ssh-add -l

# Test SSH connectivity manually
ssh -F ~/.ssh/config-proxmox ansible@socrates

# Verify Ansible configuration
ansible-config dump | grep -E '(remote_user|ssh_args|collections_path)'
```

### Terraform Infrastructure Deployment
```bash
# Deploy IaC services VM with GitLab (from terraform/gitlab/)
terraform init
terraform plan
terraform apply

# Check VM status
terraform show
terraform output

# Destroy infrastructure (if needed)
terraform destroy
```

### Testing and Validation
```bash
# Test connectivity to all hosts
ansible all -m ping

# Validate full configuration (from ansible-infrastructure/)
ansible-playbook tests/validate-setup.yml

# Dry run with changes preview
ansible-playbook site.yml --check --diff

# Check configuration dump
ansible-config dump
```

### Main Operations
```bash
# All operations from ansible-infrastructure/ directory
cd ansible-infrastructure

# Full infrastructure deployment (orchestrated setup)
ansible-playbook site.yml

# Initial server setup (for new hosts, run as root initially)
ansible-playbook playbooks/setup/initial-setup.yml -u root --ask-pass

# System maintenance
ansible-playbook playbooks/maintenance/system-update.yml
ansible-playbook playbooks/maintenance/hardware-assessment.yml

# Legacy maintenance commands (root level)
ansible-playbook proxmox-maintenance.yml
ansible-playbook gather-facts.yml
ansible-playbook update-packages.yml

# DNS infrastructure deployment
ansible-playbook playbooks/deployment/dns-lxc.yml
ansible-playbook playbooks/deployment/technitium-dns.yml
ansible-playbook playbooks/deployment/validate-dns.yml

# AI/ML deployment pipeline
ansible-playbook playbooks/deployment/docker-setup.yml
ansible-playbook playbooks/deployment/ollama-setup.yml

# Hardware-specific deployments
ansible-playbook playbooks/deployment/dell-fan-controller.yml
ansible-playbook playbooks/deployment/tailscale.yml
```

### User Management
```bash
# Set up automation users with SSH keys (run as root initially)
ansible-playbook playbooks/setup/setup-ansible-user.yml -u root

# User management (creates ansible and kellen users)
ansible-playbook playbooks/setup/initial-setup.yml

# Post-install system configuration
ansible-playbook playbooks/setup/proxmox-post-install.yml
ansible-playbook playbooks/setup/fix-proxmox-repos.yml
```

### Debugging and Troubleshooting
```bash
# Check service status across hosts
ansible all -m systemd -a "name=docker state=started"

# Verify sudo access
ansible all -m shell -a "sudo whoami"

# Gather system facts
ansible all -m setup | grep ansible_distribution

# Run single task with verbose output
ansible-playbook site.yml -v --tags "docker"
```

## Authentication & Security

### 1Password SSH Agent Integration
- SSH authentication uses 1Password SSH Agent exclusively
- SSH config at `~/.ssh/config-proxmox` contains host-specific settings
- Environment variable: `SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock`
- Get keys: `ssh-add -L` or `ssh-add -l`

### User Roles
- **kellen**: Interactive user with sudo (password required)
- **tinker**: Automation user with NOPASSWD sudo for Ansible
- **ansible**: Default remote_user set in ansible.cfg
- **iac**: Infrastructure services user for GitLab VM (created by Terraform)

### Critical Security Requirements
- **NEVER USE HARDCODED PASSWORDS** - All secrets must use Ansible Vault
- **Vault Pattern**: Use `{{ vault_variable | default(lookup('password', '/dev/null length=20 chars=ascii_letters,digits')) }}`
- **Secrets Documentation**: See SECRETS-MANAGEMENT.md for complete security implementation

### Security Features
- SSH hardening (disable root login, password auth)
- Public key authentication only
- UFW firewall rules and fail2ban
- Secure SSH timeouts and connection settings
- Ansible Vault encryption for all sensitive data

## Development Patterns

### Inventory Management
- Use hierarchical variable structure: all.yml → group_vars → host_vars → role vars
- Group structure: proxmox (virtualization) → ai_workers (ML workloads) → monitoring
- Host-specific configs in `host_vars/` (e.g., socrates.yml for main AI workstation)

### Role Development
```bash
# Create new role
ansible-galaxy init roles/role-name

# Role dependencies in meta/main.yml
# Variables in defaults/main.yml
# Tasks in tasks/main.yml
# Handlers in handlers/main.yml
```

### Collection Structure
- Custom collection: `collections/ansible_collections/kellen/infrastructure/`
- Local roles in `ansible-infrastructure/roles/` (common, user_management, ssh_hardening, etc.)
- Specialized roles: dell_idrac_fan_controller, proxmox_lxc, technitium_dns, tailscale
- Master playbook: `site.yml` orchestrates initial-setup → system-update → hardware-assessment
- Testing framework in `tests/validate-setup.yml`

### Migration Patterns
- Use `migrate-to-new-structure.sh` for transitioning legacy configurations
- Dual ansible.cfg pattern: root for quick ops, ansible-infrastructure/ for comprehensive collection work
- Legacy playbooks remain at root level for backward compatibility

## Hardware Assessment & AI/ML

The project includes automated hardware assessment specifically for AI/ML workloads:
- CPU instruction sets (AVX, AVX2, FMA)
- Memory capacity for model sizing
- GPU detection and VRAM analysis
- Storage performance recommendations

Supported AI frameworks: Ollama (local LLM), Docker (containerized AI), NVIDIA Container Toolkit, Jupyter Lab.

## Working Directory Context

When operating in this repository:
- **Always work from `ansible-infrastructure/` directory** - this contains the centralized ansible.cfg and inventory
- All playbooks and commands should be run from this location
- The project uses a single configuration approach for consistency and maintainability

## Development and Testing Workflow

### Environment Setup Validation
```bash
# From ansible-infrastructure/ - comprehensive check
./scripts/quick-setup.sh

# Quick connectivity test
ansible all -m ping --one-line
```

### Variable Debugging
```bash
# Show all variables for a host
ansible-inventory --host socrates --yaml

# List all hosts in a group
ansible all --list-hosts
ansible ai_workers --list-hosts
```

### Performance and Optimization
- Uses smart gathering with memory caching (24h timeout)
- Pipelining enabled for faster execution
- 10 parallel forks configured
- Control persist for SSH connection reuse

## GitLab Infrastructure Deployment

**ALWAYS USE TERRAFORM FOR GITLAB DEPLOYMENT** - Do not manually create VMs.

### Prerequisites (Critical SSH Fix)
```bash
# IMPORTANT: SSH connectivity was broken by dotfiles XDG compliance
# This MUST be resolved before Terraform will work:
# Either disable IdentitiesOnly in SSH config OR use this flag:
ssh -o IdentitiesOnly=no [target]

# Verify 1Password SSH agent is working:
ssh-add -l

# Test SSH connectivity to Proxmox:
ssh -F ~/.ssh/config-proxmox -o IdentitiesOnly=no root@socrates
```

### Standard Terraform Deployment
```bash
# 1. Deploy VM infrastructure with Terraform (PRIMARY METHOD)
cd terraform/gitlab
terraform init
terraform plan
terraform apply

# 2. Services are auto-configured via cloud-init
# GitLab stack will be available at:
# - https://gitlab.doofus.co (external)
# - https://gitlab.rawls.ts.net (Tailscale)
```

### Ansible-Only Deployment (For other services)
```bash
# Use for non-GitLab services on existing hosts
cd ansible-infrastructure
ansible-playbook playbooks/deployment/technitium-dns-container.yml
ansible-playbook playbooks/deployment/docker-setup.yml
```

### Manual Deployment (EMERGENCY ONLY)
⚠️  **Only use if Terraform fails completely**
```bash
# Last resort - creates "jank" deployment that should be torn down
# and replaced with proper Terraform deployment
echo "Use Terraform instead - manual deployment creates technical debt"
```

## Service Access Patterns

### GitLab Access (Terraform deployed)
- **External**: https://gitlab.doofus.co
- **Tailscale**: https://gitlab.rawls.ts.net  
- **SSH Git**: `git clone git@gitlab.doofus.co:2222/user/repo.git`
- **VM SSH**: `ssh iac@[terraform-assigned-ip]` (check terraform output)

### Teardown Manual Instances
```bash
# Remove any manual "jank" deployments before using Terraform
ssh -o IdentitiesOnly=no ansible@10.203.3.60 'sudo docker compose -f /opt/gitlab-stack/docker-compose.yml down'
# Then delete VM from Proxmox web interface
```

### DNS Server Access (Ansible deployed)
- **Web Interface**: http://rseau:5380
- **API**: http://rseau:5380/api/
- **SSH**: `ssh ansible@rseau`

## Phase-based Deployment

### Phase 1: Core Services ✅
- GitLab CE with Caddy reverse proxy
- Technitium DNS server
- Basic security hardening

### Phase 2: Enhanced Services
- Semaphore UI for Ansible management
- Extended monitoring with Prometheus

### Phase 3: Advanced Orchestration
- Kestra workflow engine
- Kubernetes migration preparation