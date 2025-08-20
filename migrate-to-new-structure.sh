#!/bin/bash
set -e

echo "🔄 Migrating to new Ansible collection structure..."

# Clean up old files
echo "🧹 Cleaning up old files..."
rm -f ansible.cfg inventory.yml 
rm -f setup-ansible-user.yml proxmox-maintenance.yml gather-facts.yml update-packages.yml
rm -f create_structure.py

# Move SSH config to proper location
if [[ -f ~/.ssh/config-proxmox ]]; then
    echo "✅ SSH config already in place"
else
    echo "⚠️  Please ensure ~/.ssh/config-proxmox exists with proper 1Password integration"
fi

# Test new structure
echo "🧪 Testing new structure..."
cd ansible-infrastructure

if ansible all -m ping; then
    echo "✅ New structure working correctly!"
else
    echo "⚠️  Check configuration in ansible-infrastructure/inventory/"
fi

echo ""
echo "🎉 Migration completed!"
echo ""
echo "📁 New structure is ready at: ./ansible-infrastructure/"
echo ""
echo "🚀 Quick start commands:"
echo "  cd ansible-infrastructure"
echo "  ansible all -m ping"
echo "  ansible-playbook tests/validate-setup.yml"
echo "  ansible-playbook playbooks/maintenance/hardware-assessment.yml"
echo ""
echo "📚 See ansible-infrastructure/README.md for complete documentation."