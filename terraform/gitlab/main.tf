# GitLab + Future Semaphore/Kestra VM on rawls with Caddy reverse proxy
# Phase 1: GitLab, Phase 2: +Semaphore, Phase 3: +Kestra
# Integrates with Tailscale magic domains and doofus.co

terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "~> 2.9"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

# Proxmox provider configuration - targeting rawls
provider "proxmox" {
  pm_api_url          = var.proxmox_api_url
  pm_api_token_id     = "terraform@pve!tf"
  pm_api_token_secret = "278e2dd6-fc47-4174-a5d4-16b74b869f67"
  pm_tls_insecure     = true
}

# Cloudflare provider for DNS management (disabled for initial deployment)
# provider "cloudflare" {
#   api_token = var.cloudflare_api_token
# }

# IaC Services VM on rawls (GitLab + future Semaphore/Kestra)
resource "proxmox_vm_qemu" "iac_services" {
  name        = "iac-services"
  target_node = var.proxmox_node
  
  # VM Configuration - sized for GitLab + Semaphore + Kestra
  cores   = 8   # Plenty for all services + CI runners
  memory  = 16384  # 16GB for growth (GitLab 8GB + Semaphore 2GB + Kestra 4GB + buffer)
  scsihw  = "virtio-scsi-pci"
  
  # Boot configuration
  boot = "order=scsi0"
  
  # Network configuration
  network {
    model  = "virtio"
    bridge = "vmbr0"
  }
  
  # Primary disk - sized for all services and data
  disk {
    type    = "scsi"
    storage = var.proxmox_storage
    size    = "120G"  # Space for GitLab repos, CI artifacts, and future services
    format  = "qcow2"
  }
  
  # Cloud-init configuration
  os_type = "cloud-init"
  
  # Cloud-init drive
  disk {
    type    = "cloudinit"
    storage = var.proxmox_storage
    size    = "1G"
  }
  
  # IP configuration for homelab network
  ipconfig0 = "ip=${var.iac_services_ip}/24,gw=${var.gateway_ip}"
  nameserver = var.dns_servers
  
  # SSH keys
  sshkeys = var.ssh_public_key
  
  # Cloud-init user data - inline configuration
  ciuser     = "iac"
  cipassword = "TempPassword123!"
  
  # Start after creation
  automatic_reboot = true
  
  lifecycle {
    ignore_changes = [
      network,
      disk,
    ]
  }
}

# Cloudflare DNS records for external access (disabled for initial deployment)
# resource "cloudflare_record" "gitlab" {
#   zone_id = var.cloudflare_zone_id
#   name    = "gitlab"
#   value   = var.tailscale_ip
#   type    = "A"
#   ttl     = 300
#   comment = "GitLab CE on rawls via Tailscale"
# }

# resource "cloudflare_record" "semaphore" {
#   zone_id = var.cloudflare_zone_id
#   name    = "semaphore"
#   value   = var.tailscale_ip
#   type    = "A"
#   ttl     = 300
#   comment = "Semaphore IaC UI on rawls via Tailscale"
# }

# resource "cloudflare_record" "kestra" {
#   zone_id = var.cloudflare_zone_id
#   name    = "kestra"
#   value   = var.tailscale_ip
#   type    = "A"
#   ttl     = 300
#   comment = "Kestra workflow orchestration on rawls via Tailscale"
# }

# Output important information
output "iac_services_ip" {
  value = var.iac_services_ip
}

output "gitlab_urls" {
  value = {
    external = "https://gitlab.doofus.co"
    tailscale = "https://gitlab.rawls.ts.net"
  }
}

output "semaphore_urls" {
  value = {
    external = "https://semaphore.doofus.co"
    tailscale = "https://semaphore.rawls.ts.net"
  }
}

output "kestra_urls" {
  value = {
    external = "https://kestra.doofus.co"
    tailscale = "https://kestra.rawls.ts.net"
  }
}

output "ssh_command" {
  value = "ssh iac@${var.iac_services_ip}"
}