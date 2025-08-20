#!/bin/bash
set -e

# Quick setup script for Ansible Infrastructure Collection
# Usage: ./scripts/quick-setup.sh

echo "🚀 Ansible Infrastructure Collection - Quick Setup"
echo "=================================================="

# Check prerequisites
echo "📋 Checking prerequisites..."

# Check if ansible is installed
if ! command -v ansible &> /dev/null; then
    echo "❌ Ansible is not installed. Please install Ansible 2.14+."
    exit 1
fi

# Check ansible version
ANSIBLE_VERSION=$(ansible --version | head -n1 | awk '{print $3}' | cut -d. -f1,2)
if [[ $(echo "$ANSIBLE_VERSION < 2.14" | bc) -eq 1 ]]; then
    echo "❌ Ansible version $ANSIBLE_VERSION is too old. Please upgrade to 2.14+."
    exit 1
fi
echo "✅ Ansible $ANSIBLE_VERSION detected"

# Check 1Password SSH agent
if [[ -z "$SSH_AUTH_SOCK" ]]; then
    echo "⚠️  SSH_AUTH_SOCK not set. Make sure 1Password SSH agent is configured."
else
    echo "✅ SSH agent detected: $SSH_AUTH_SOCK"
fi

# Check SSH keys
if ssh-add -l &> /dev/null; then
    KEY_COUNT=$(ssh-add -l | wc -l)
    echo "✅ SSH keys available: $KEY_COUNT"
else
    echo "⚠️  No SSH keys found in agent"
fi

# Test connectivity
echo ""
echo "🔍 Testing connectivity..."
if ansible all -m ping --one-line 2>/dev/null; then
    echo "✅ All hosts reachable"
else
    echo "⚠️  Some hosts may not be reachable. Check inventory configuration."
fi

# Display inventory summary
echo ""
echo "📊 Inventory Summary:"
ansible all --list-hosts | sed 's/^/  /'

echo ""
echo "🎯 Available Playbooks:"
echo "  Setup:"
find playbooks/setup -name "*.yml" -exec basename {} \; | sed 's/^/    /'
echo "  Maintenance:" 
find playbooks/maintenance -name "*.yml" -exec basename {} \; | sed 's/^/    /'
echo "  Deployment:"
find playbooks/deployment -name "*.yml" -exec basename {} \; | sed 's/^/    /'

echo ""
echo "🚀 Quick Start Commands:"
echo "  Full setup:           ansible-playbook site.yml"
echo "  Initial setup only:   ansible-playbook playbooks/setup/initial-setup.yml"
echo "  Hardware assessment:  ansible-playbook playbooks/maintenance/hardware-assessment.yml"
echo "  System updates:       ansible-playbook playbooks/maintenance/system-update.yml"
echo "  Docker setup:         ansible-playbook playbooks/deployment/docker-setup.yml"
echo "  Ollama setup:         ansible-playbook playbooks/deployment/ollama-setup.yml"
echo "  Validate setup:       ansible-playbook tests/validate-setup.yml"

echo ""
echo "📚 Documentation:"
echo "  Main README:          README.md"
echo "  Test connectivity:    ansible all -m ping"
echo "  Check configuration:  ansible-config dump"

echo ""
echo "✅ Setup check completed! Ready to run playbooks."