# Proxmox Ansible Setup Guide

## 1Password SSH Agent Setup

### Enable 1Password SSH Agent (one-time setup)
1. Open 1Password app → Settings → Developer → SSH Agent
2. Enable "Use the SSH agent" 
3. Enable "Display key names when authorizing connections"

### Configure your shell (add to ~/.zshrc or ~/.bashrc)
```bash
export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
```

### Get your SSH public keys from 1Password
```bash
# List available keys
ssh-add -L

# Or get specific key info
ssh-add -l
```

## Initial Server Setup (as root)

### 1. Get your public keys from 1Password
Copy the public key output from `ssh-add -L` - you'll need these for the setup playbook.

### 2. Update the setup-users.yml file
Edit `setup-users.yml` and replace the placeholder SSH keys with your actual public keys from 1Password:
```yaml
kellen_ssh_key: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... kellen@1password"
tinker_ssh_key: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... tinker@1password"  
```

### 3. Run the user setup (as root initially)
```bash
# Update inventory to use root initially
ansible-playbook setup-users.yml -u root
```

### 4. Test the new users
```bash
# Test kellen user
ssh kellen@10.203.3.42

# Test tinker user  
ssh tinker@10.203.3.42
```

### 5. Switch to tinker user for automation
Your `inventory.yml` is already configured to use the `tinker` user for ongoing automation tasks.

## User Permissions Explained

### kellen user:
- Member of `sudo` and `adm` groups
- Can run commands with `sudo` (will prompt for password)
- Can read system logs (adm group)
- Regular user account for interactive use

### tinker user:
- Member of `sudo` group
- **NOPASSWD sudo** - can run any command without password prompt
- Designed specifically for Ansible automation
- Should only be used for automation, not interactive sessions

## Security Considerations

The setup playbook will:
- ✅ Disable root SSH login
- ✅ Disable password authentication (keys only)
- ✅ Enable public key authentication
- ✅ Set secure SSH timeouts
- ✅ Backup SSH config before changes

## Running Playbooks After Setup

Once users are created, use these commands:

```bash
# Hardware assessment and package updates
ansible-playbook proxmox-maintenance.yml

# Just gather facts
ansible-playbook gather-facts.yml

# Just update packages  
ansible-playbook update-packages.yml

# Test connectivity
ansible proxmox -m ping
```

## Troubleshooting

### SSH Key Issues
```bash
# Verify 1Password SSH agent is working
ssh-add -l

# Test SSH connection manually
ssh -v tinker@10.203.3.42
```

### Permission Issues
```bash
# Check user was created properly
ansible proxmox -m shell -a "id tinker"

# Test sudo access
ansible proxmox -m shell -a "sudo whoami"
```

### SSH Configuration
```bash
# Test SSH config is valid
ansible proxmox -m shell -a "sudo sshd -t"
```

## Next Steps After Hardware Assessment

Once you run `proxmox-maintenance.yml`, you'll have a detailed hardware report in `/tmp/proxmox_ai_hardware_report.txt` that will help determine:

- Which AI/ML models your hardware can support
- Memory requirements for different model sizes
- CPU capabilities for AI workloads
- Storage considerations for model files

This report will be perfect for asking Claude Code about optimal AI model recommendations for your specific hardware!