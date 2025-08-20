# Ansible Infrastructure Collection

A comprehensive Ansible collection for infrastructure automation, specializing in Proxmox virtualization, AI/ML workloads, and security hardening.

## 🏗️ Architecture

```
ansible-infrastructure/
├── collections/                 # Ansible collections
├── inventory/                  # Inventory management
│   ├── hosts.yml              # Main inventory
│   ├── group_vars/            # Group variables
│   └── host_vars/             # Host-specific variables
├── playbooks/                 # Organized playbooks
│   ├── setup/                 # Initial setup playbooks
│   ├── maintenance/           # System maintenance
│   ├── deployment/            # Application deployment
│   └── monitoring/            # Monitoring setup
├── roles/                     # Custom roles
├── tests/                     # Testing framework
└── docs/                      # Documentation
```

## 🚀 Quick Start

### Prerequisites

1. **1Password SSH Agent** configured and running
2. **Ansible** 2.14+ installed
3. **SSH access** to target hosts

### Initial Setup

1. **Clone and navigate to the collection:**
   ```bash
   cd ansible-infrastructure
   ```

2. **Configure your inventory:**
   ```bash
   # Edit inventory/hosts.yml with your hosts
   # Update group_vars/ and host_vars/ as needed
   ```

3. **Test connectivity:**
   ```bash
   ansible all -m ping
   ```

4. **Run initial setup:**
   ```bash
   # For new hosts (run as root initially)
   ansible-playbook playbooks/setup/initial-setup.yml -u root --ask-pass
   
   # For existing hosts
   ansible-playbook playbooks/setup/initial-setup.yml
   ```

## 📚 Playbook Categories

### Setup Playbooks
- `setup/initial-setup.yml` - Complete initial server setup
- `setup/user-management.yml` - User and SSH key management

### Maintenance Playbooks  
- `maintenance/system-update.yml` - System updates and patches
- `maintenance/hardware-assessment.yml` - Hardware analysis for AI/ML

### Deployment Playbooks
- `deployment/docker-setup.yml` - Docker and container runtime
- `deployment/ollama-setup.yml` - Local LLM serving with Ollama

### Monitoring Playbooks
- `monitoring/prometheus-setup.yml` - Prometheus monitoring
- `monitoring/grafana-setup.yml` - Grafana dashboards

## 🎯 Common Use Cases

### 1. New Server Setup
```bash
# Complete setup from scratch
ansible-playbook site.yml -u root --ask-pass
```

### 2. System Maintenance
```bash
# Update all systems
ansible-playbook playbooks/maintenance/system-update.yml

# Hardware assessment
ansible-playbook playbooks/maintenance/hardware-assessment.yml
```

### 3. AI/ML Workload Deployment
```bash
# Install Docker and AI tools
ansible-playbook playbooks/deployment/docker-setup.yml
ansible-playbook playbooks/deployment/ollama-setup.yml
```

## 🔧 Configuration

### Inventory Structure

The inventory uses a hierarchical structure:

- **`all`** - Global variables
- **`proxmox`** - Proxmox virtualization hosts
- **`ai_workers`** - Hosts for AI/ML workloads
- **`monitoring`** - Monitoring infrastructure

### Variable Hierarchy

1. `inventory/group_vars/all.yml` - Global defaults
2. `inventory/group_vars/[group].yml` - Group-specific variables  
3. `inventory/host_vars/[host].yml` - Host-specific variables
4. Role defaults and variables

### SSH Configuration

The collection integrates with 1Password SSH Agent:

```yaml
# ansible.cfg
[ssh_connection]
ssh_args = -F ~/.ssh/config-proxmox -o ControlMaster=auto -o ControlPersist=60s -o ForwardAgent=yes
```

## 🔒 Security Features

- **SSH Hardening** - Disable root login, password auth
- **User Management** - Automated user creation and key deployment
- **Firewall Configuration** - UFW rules and fail2ban
- **1Password Integration** - Secure key management without files

## 🤖 AI/ML Capabilities

### Hardware Assessment
Automatically analyzes hardware for AI/ML suitability:
- CPU instruction sets (AVX, AVX2, FMA)
- Memory capacity for model sizing
- GPU detection and VRAM analysis
- Storage performance recommendations

### Supported AI Frameworks
- **Ollama** - Local LLM serving
- **Docker** - Containerized AI workloads  
- **NVIDIA Container Toolkit** - GPU acceleration
- **Jupyter Lab** - Development environment

## 🧪 Testing

### Test Connectivity
```bash
ansible all -m ping
```

### Validate Configuration
```bash
ansible-playbook tests/validate-setup.yml
```

### Dry Run
```bash
ansible-playbook site.yml --check --diff
```

## 📝 Development

### Adding New Roles
```bash
# Create role structure
ansible-galaxy init roles/my-new-role

# Add to playbooks
- roles:
  - my-new-role
```

### Variable Management
- Use `group_vars/` for shared configuration
- Use `host_vars/` for host-specific settings
- Encrypt sensitive data with `ansible-vault`

## 🐛 Troubleshooting

### SSH Connection Issues
```bash
# Test SSH manually
ssh -F ~/.ssh/config-proxmox ansible@your-host

# Check 1Password SSH agent
ssh-add -l
```

### Permission Issues
```bash
# Verify sudo access
ansible all -m shell -a "sudo whoami"
```

### Service Issues
```bash
# Check service status
ansible all -m systemd -a "name=docker state=started"
```

## 📄 License

MIT License - see LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Test changes thoroughly  
4. Submit pull request

## 📞 Support

- **Issues**: GitHub Issues
- **Documentation**: `/docs` directory
- **Examples**: `/tests` directory