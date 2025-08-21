#!/bin/bash
# GitLab Deployment Script with 1Password Integration
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TERRAFORM_DIR="$PROJECT_ROOT/terraform/gitlab"
ANSIBLE_DIR="$PROJECT_ROOT/ansible-infrastructure"

echo "🚀 HomeLab GitLab Deployment Pipeline"
echo "====================================="

# Check prerequisites
echo "📋 Checking prerequisites..."

# Check if 1Password CLI is available
if ! command -v op &> /dev/null; then
    echo "❌ 1Password CLI not found. Please install: brew install 1password-cli"
    exit 1
fi

# Check if logged into 1Password
if ! op account list &> /dev/null; then
    echo "❌ Not logged into 1Password. Please run: op signin"
    exit 1
fi

# Check Terraform
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform not found. Please install Terraform"
    exit 1
fi

# Check Ansible
if ! command -v ansible &> /dev/null; then
    echo "❌ Ansible not found. Please install Ansible"
    exit 1
fi

echo "✅ Prerequisites check passed"

# Change to Terraform directory
cd "$TERRAFORM_DIR"

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    echo "❌ terraform.tfvars not found. Please create it from the template."
    exit 1
fi

# Retrieve Tailscale auth key from 1Password
echo "🔐 Retrieving secrets from 1Password..."
TAILSCALE_AUTH_KEY=$(op read "op://Private/ts_gitlab_authkey/credential" 2>/dev/null || echo "")

if [ -z "$TAILSCALE_AUTH_KEY" ]; then
    echo "❌ Failed to retrieve Tailscale auth key from 1Password"
    echo "   Please ensure the item 'ts_gitlab_authkey' exists in your 'Private' vault"
    exit 1
fi

# Create temporary tfvars file with secrets
echo "📝 Preparing deployment configuration..."
cp terraform.tfvars terraform.tfvars.tmp

# Replace 1Password reference with actual key
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s|op://Private/ts_gitlab_authkey/credential|$TAILSCALE_AUTH_KEY|g" terraform.tfvars.tmp
else
    # Linux
    sed -i "s|op://Private/ts_gitlab_authkey/credential|$TAILSCALE_AUTH_KEY|g" terraform.tfvars.tmp
fi

# Initialize Terraform
echo "🏗️  Initializing Terraform..."
terraform init

# Plan deployment
echo "📊 Planning Terraform deployment..."
terraform plan -var-file="terraform.tfvars.tmp"

# Confirm deployment
read -p "🚦 Deploy GitLab infrastructure? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Apply Terraform
    echo "🚀 Deploying infrastructure..."
    terraform apply -var-file="terraform.tfvars.tmp" -auto-approve
    
    # Get VM IP
    VM_IP=$(terraform output -raw vm_ip 2>/dev/null || echo "10.203.3.60")
    
    echo "✅ Infrastructure deployed successfully!"
    echo "📍 VM IP: $VM_IP"
    
    # Clean up temporary file
    rm -f terraform.tfvars.tmp
    
    # Wait for VM to be ready
    echo "⏳ Waiting for VM to be ready..."
    sleep 30
    
    # Run Ansible configuration
    echo "🔧 Running Ansible configuration..."
    cd "$ANSIBLE_DIR"
    
    # Update inventory if needed
    export ANSIBLE_CONFIG="$ANSIBLE_DIR/ansible.cfg"
    
    # Test connectivity
    if ansible all -m ping; then
        echo "📦 Deploying GitLab stack..."
        ansible-playbook playbooks/deployment/gitlab-stack.yml
        
        echo "🎉 GitLab deployment completed!"
        echo "🌐 GitLab URL: https://gitlab.doofus.co"
        echo "🔗 Tailscale URL: https://gitlab.rawls.ts.net"
        echo "💻 SSH Access: ssh iac@$VM_IP"
    else
        echo "⚠️  Ansible connectivity failed. Manual configuration may be needed."
    fi
else
    echo "❌ Deployment cancelled"
    rm -f terraform.tfvars.tmp
fi

echo "🏁 Deployment script completed"