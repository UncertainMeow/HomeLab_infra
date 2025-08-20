# 🔒 Secrets Management Guide

**SECURITY CRITICAL**: This document outlines mandatory practices for handling secrets in the HomeLab infrastructure.

## 🚨 Security Principles

1. **NO HARDCODED SECRETS** - All secrets must be externalized
2. **Ansible Vault** - All sensitive data encrypted at rest
3. **Environment Variables** - Runtime secrets via secure environment injection
4. **1Password Integration** - SSH keys managed via 1Password SSH Agent
5. **Regular Rotation** - All secrets must be rotatable without code changes

## 🛡️ Current Security Issues Identified

### ❌ FOUND: Hardcoded Default Passwords

The following files contain hardcoded default passwords that **MUST BE CHANGED**:

```yaml
# SECURITY VIOLATION - DO NOT USE THESE DEFAULTS
gitlab_initial_root_password: "GitLabAdmin123!"     # roles/gitlab_stack/defaults/main.yml
dns_admin_password: "TechAdmin123!"                  # playbooks/deployment/technitium-dns-container.yml  
semaphore_admin_password: "SemaphoreAdmin123!"      # roles/gitlab_stack/defaults/main.yml
kestra_db_password: "KestraDB123!"                   # roles/gitlab_stack/defaults/main.yml
```

### ✅ Proper Vault Pattern Implementation

All secrets should follow this pattern:

```yaml
# CORRECT PATTERN
gitlab_initial_root_password: "{{ vault_gitlab_root_password | default(lookup('password', '/dev/null length=20 chars=ascii_letters,digits')) }}"
```

## 🔐 Mandatory Vault Setup

### Step 1: Create Vault Files

```bash
# Create vault directory structure
mkdir -p ansible-infrastructure/inventory/group_vars/all/

# Create encrypted vault file
ansible-vault create ansible-infrastructure/inventory/group_vars/all/vault.yml
```

### Step 2: Vault Content Template

```yaml
---
# GitLab Secrets
vault_gitlab_root_password: "{{ lookup('password', '/dev/null length=20 chars=ascii_letters,digits,punctuation') }}"

# DNS Secrets  
vault_dns_admin_password: "{{ lookup('password', '/dev/null length=20 chars=ascii_letters,digits,punctuation') }}"

# Tailscale Secrets
vault_tailscale_auth_key: "tskey-auth-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

# Semaphore Secrets (Phase 2)
vault_semaphore_admin_password: "{{ lookup('password', '/dev/null length=20 chars=ascii_letters,digits,punctuation') }}"

# Kestra Secrets (Phase 3)
vault_kestra_db_password: "{{ lookup('password', '/dev/null length=20 chars=ascii_letters,digits,punctuation') }}"

# Proxmox API Secrets
vault_proxmox_password: "your_proxmox_root_password"

# Dell iDRAC Secrets
vault_dell_idrac_password: "your_idrac_password"

# Cloudflare API Secrets  
vault_cloudflare_api_token: "your_cloudflare_api_token"
vault_cloudflare_zone_id: "your_cloudflare_zone_id"
```

### Step 3: SSH Key Management

SSH keys are handled via 1Password SSH Agent:

```bash
# Verify SSH keys available
ssh-add -L

# Expected output format for inventory
ssh_public_keys:
  - "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... comment"
```

## 🔒 Secrets by Service

### GitLab Stack Secrets

| Secret | Vault Variable | Usage | Rotation |
|--------|----------------|--------|----------|
| GitLab Root Password | `vault_gitlab_root_password` | Initial admin login | Change on first login |
| Tailscale Auth Key | `vault_tailscale_auth_key` | Network access | Generate new key monthly |

### DNS Server Secrets

| Secret | Vault Variable | Usage | Rotation |
|--------|----------------|--------|----------|
| Admin Password | `vault_dns_admin_password` | Web interface login | Monthly |

### Infrastructure Secrets

| Secret | Vault Variable | Usage | Rotation |
|--------|----------------|--------|----------|
| Proxmox Password | `vault_proxmox_password` | API access | Quarterly |
| SSH Public Keys | Via 1Password Agent | System access | As needed |

## ⚠️ IMMEDIATE ACTION REQUIRED

### Fix Hardcoded Passwords

Update these files immediately:

1. **`roles/gitlab_stack/defaults/main.yml`**:
```yaml
# BEFORE (INSECURE)
gitlab_initial_root_password: "GitLabAdmin123!"

# AFTER (SECURE)
gitlab_initial_root_password: "{{ vault_gitlab_root_password | default(lookup('password', '/dev/null length=20 chars=ascii_letters,digits')) }}"
```

2. **`playbooks/deployment/technitium-dns-container.yml`**:
```yaml
# BEFORE (INSECURE) 
dns_admin_password: "TechAdmin123!"

# AFTER (SECURE)
dns_admin_password: "{{ vault_dns_admin_password | default(lookup('password', '/dev/null length=20 chars=ascii_letters,digits')) }}"
```

### Create Vault Password File

```bash
# Create vault password file (store this securely)
echo "your_vault_password_here" > ~/.ansible_vault_password
chmod 600 ~/.ansible_vault_password

# Configure ansible.cfg
cat >> ansible-infrastructure/ansible.cfg << EOF
vault_password_file = ~/.ansible_vault_password
EOF
```

## 🛠️ Secure Deployment Commands

### With Vault

```bash
# Deploy with vault decryption
ansible-playbook playbooks/deployment/gitlab-stack.yml --ask-vault-pass

# Or with password file
ansible-playbook playbooks/deployment/gitlab-stack.yml
```

### Generate Secure Passwords

```bash
# Generate secure passwords
ansible all -i localhost, -c local -m debug -a "msg={{ lookup('password', '/dev/null length=20 chars=ascii_letters,digits,punctuation') }}"
```

## 🔍 Security Validation

### Audit Commands

```bash
# Check for hardcoded secrets
grep -r -E "(password|secret|key)" --include="*.yml" . | grep -v vault | grep -v lookup

# Verify vault encryption
ansible-vault view ansible-infrastructure/inventory/group_vars/all/vault.yml

# Test vault decryption in playbook
ansible-playbook --check playbooks/deployment/gitlab-stack.yml
```

### Pre-deployment Security Checklist

- [ ] All vault files encrypted with `ansible-vault encrypt`
- [ ] No hardcoded passwords in any `.yml` files  
- [ ] Vault password file secured with `chmod 600`
- [ ] SSH keys managed via 1Password SSH Agent
- [ ] All default passwords changed from examples
- [ ] API keys stored in vault, not plaintext
- [ ] Backup of vault password stored securely offline

## 🚨 Incident Response

### If Secrets Are Compromised

1. **Immediate Actions**:
   - Rotate ALL affected passwords
   - Revoke API keys and generate new ones
   - Check access logs for unauthorized usage
   - Update vault with new secrets

2. **GitLab Compromise**:
   ```bash
   # Reset GitLab root password
   docker exec -it gitlab gitlab-rails console
   user = User.where(id: 1).first
   user.password = 'new_secure_password'  
   user.password_confirmation = 'new_secure_password'
   user.save!
   ```

3. **DNS Server Compromise**:
   - Access Technitium admin interface
   - Change admin password immediately
   - Review DNS zone configurations for tampering

## 📋 Security Maintenance

### Monthly Tasks

- [ ] Rotate Tailscale auth keys
- [ ] Update DNS admin passwords
- [ ] Review access logs for anomalies
- [ ] Audit vault file permissions

### Quarterly Tasks  

- [ ] Rotate Proxmox API passwords
- [ ] Update SSH key pairs
- [ ] Review and update vault encryption keys
- [ ] Security assessment of all services

## 🎯 Best Practices

### Development

- **Never commit** `.yml` files with actual passwords
- **Always use** `{{ vault_variable | default(lookup('password', ...)) }}` pattern
- **Test deployments** with `--check` flag first
- **Document** all vault variables in this file

### Production

- **Separate vault files** for different environments
- **Backup vault passwords** to secure offline storage
- **Monitor** failed authentication attempts
- **Automate** password rotation where possible

---

## 🆘 Emergency Contacts

- **Vault Password Recovery**: Check 1Password "HomeLab Vault" entry
- **SSH Key Issues**: Use 1Password SSH Agent recovery
- **Service Lockout**: Console access to Proxmox hosts