# Changelog

All notable changes to the HomeLab Infrastructure project will be documented in this file.

## [Unreleased]
### Added
- Tailscale role: optional DNS server configuration via `tailscale_dns_servers`
- DNS zone setup script: openwebui record and corrected htpc IP
- Playbook: `docker-compose-nas.yml` to deploy NAS stack on htpc

## [2.0.0] - 2025-08-20

### 🚀 Major Features Added

#### GitLab CE Stack Deployment
- **Complete GitLab CE deployment** with Caddy reverse proxy integration
- **Automated Docker Compose** orchestration for GitLab + Caddy services
- **Tailscale magic domains** support for secure remote access
- **Production-ready security hardening** with UFW firewall and fail2ban
- **Automated backup system** with daily backups and retention policies
- **Performance optimization** for homelab resource constraints

#### DNS Infrastructure
- **Technitium DNS server** containerized deployment
- **Web-based DNS management** interface with API support
- **Internal domain resolution** for homelab services
- **Dynamic zone configuration** via automated scripts

#### Infrastructure as Code Services
- **New host group**: `iac_services` for infrastructure management services
- **Scalable architecture**: Ready for Semaphore (Phase 2) and Kestra (Phase 3)
- **Container orchestration ready**: Prepared for k3s/Docker Swarm migration

### 🏗️ New Ansible Components

#### Roles Created
- **`gitlab_stack`** - Comprehensive GitLab CE + Caddy + Tailscale integration
  - System preparation and Docker setup
  - GitLab container configuration with reverse proxy
  - Caddy configuration with automatic HTTPS
  - Security hardening (UFW, fail2ban)
  - Automated backup configuration
  - Tailscale integration for secure access

#### Playbooks Added
- **`playbooks/deployment/gitlab-stack.yml`** - Main GitLab stack deployment
- **`playbooks/deployment/technitium-dns-container.yml`** - DNS server deployment
- Templates for DNS zone setup and configuration

#### Configuration Updates
- **`ansible.cfg`** - Centralized Ansible configuration
- **`inventory/hosts.yml`** - Added rawls host and iac_services group
- **Enhanced documentation** with comprehensive deployment guides

### 🔧 Templates and Automation

#### GitLab Stack Templates
- **`docker-compose.yml.j2`** - GitLab CE and Caddy orchestration
- **`Caddyfile.j2`** - Reverse proxy configuration with Tailscale domains
- **`gitlab-backup.sh.j2`** - Automated backup script with retention
- **`gitlab-cleanup.sh.j2`** - Backup cleanup and maintenance
- **`gitlab.env.j2`** - Environment configuration management

#### System Configuration
- **Security hardening** templates for UFW and fail2ban
- **Docker configuration** with performance optimization
- **Log rotation** and system maintenance automation

### 📊 Infrastructure Improvements

#### Host Management
- **Added rawls** (10.203.3.47) as secondary Proxmox node for IaC services
- **Updated inventory structure** with logical service groupings
- **Improved variable hierarchy** for better configuration management

#### Network Architecture
- **Dual-access pattern**: External (domain.com) and internal (Tailscale) access
- **Reverse proxy consolidation** via Caddy for all HTTP/HTTPS traffic
- **Security-first design** with minimal port exposure and encrypted connections

### 🛡️ Security Enhancements

#### Automated Security Hardening
- **SSH hardening** with key-only authentication and secure timeouts
- **UFW firewall** configuration with minimal required ports
- **fail2ban** intrusion prevention for GitLab and SSH
- **Docker security** profiles and container isolation

#### Access Control
- **1Password SSH Agent** integration for secure key management
- **Tailscale VPN** for secure remote access to services
- **Role-based access** with ansible user for automation and kellen for administration

### 📚 Documentation

#### Comprehensive Guides
- **README.md** - Complete project overview with quick start guide
- **DEPLOYMENT-GUIDE.md** - Step-by-step deployment instructions
- **CLAUDE.md** - Enhanced AI assistant context with new infrastructure patterns

#### Inline Documentation
- **Playbook comments** with detailed explanations
- **Role documentation** with usage examples and variable descriptions
- **Template annotations** for configuration understanding

### ⚡ Performance Optimizations

#### GitLab Configuration
- **Memory optimization** for homelab resource constraints
- **Database tuning** with appropriate connection limits and buffer sizes
- **Container resource** allocation and shared memory configuration

#### System Performance
- **Docker optimization** with log rotation and resource limits
- **Ansible performance** tuning with pipelining and parallel execution
- **Network optimization** with connection persistence and compression

### 🔮 Future Readiness

#### Scalability Preparation
- **Phase 2 ready**: Semaphore integration prepared (commented configurations)
- **Phase 3 ready**: Kestra workflow orchestration framework
- **Container orchestration**: Architecture prepared for k3s cluster migration

#### Hardware Expansion
- **MS-01 cluster ready**: Infrastructure patterns support easy node addition
- **Service migration**: Docker volumes and configurations ready for cluster deployment
- **High availability**: Patterns established for service redundancy

### 🧪 Testing and Validation

#### Deployment Validation
- **Successful deployment** on production homelab infrastructure
- **Service health checks** and monitoring integration
- **Backup verification** and restore procedures tested

#### Infrastructure Testing
- **Connectivity validation** across all service components
- **Security testing** of firewall rules and access controls
- **Performance testing** under typical homelab workloads

## Implementation Timeline

- **Infrastructure Planning**: Host architecture and service design
- **Ansible Development**: Role creation and playbook development
- **Security Implementation**: Hardening and access control setup
- **Deployment Execution**: Live deployment on production infrastructure
- **Documentation**: Comprehensive guides and operational documentation
- **Testing and Validation**: Service verification and performance validation

## Breaking Changes

### Inventory Structure
- **New host group** `iac_services` replaces ad-hoc GitLab targeting
- **Updated host definitions** with rawls as secondary Proxmox node

### Configuration Management
- **Centralized ansible.cfg** replaces individual playbook configurations
- **Enhanced variable hierarchy** may require existing variable updates

## Migration Guide

For existing installations:

1. **Update inventory** to include new host groups and rawls configuration
2. **Deploy new roles** using provided playbooks
3. **Migrate existing services** to new architecture patterns
4. **Update documentation** references to new structure

## Acknowledgments

This major release represents a significant infrastructure evolution, providing:
- **Production-ready GitLab CE** with enterprise-grade features
- **Scalable service architecture** ready for future expansion
- **Comprehensive automation** reducing manual infrastructure management
- **Security-first design** with multiple layers of protection

**Total Effort**: ~8 hours of development, testing, and documentation
**Files Created**: 25+ new files including roles, playbooks, templates, and documentation
**Lines of Code**: 2000+ lines of Ansible automation and configuration