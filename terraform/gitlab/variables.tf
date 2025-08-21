# Variables for IaC Services VM (GitLab + Semaphore + Kestra) on rawls

# Proxmox Configuration - targeting rawls
variable "proxmox_api_url" {
  description = "Proxmox API URL"
  type        = string
  default     = "https://10.203.3.47:8006/api2/json"  # rawls (Ryzen 7 5800H)
}

variable "proxmox_user" {
  description = "Proxmox user for API access"
  type        = string
  default     = "root@pam"
}

variable "proxmox_password" {
  description = "Proxmox password"
  type        = string
  sensitive   = true
}

variable "proxmox_node" {
  description = "Proxmox node name"
  type        = string
  default     = "rawls"
}

variable "proxmox_storage" {
  description = "Proxmox storage pool"
  type        = string
  default     = "local-lvm"
}

# Network Configuration
variable "iac_services_ip" {
  description = "Static IP for IaC Services VM"
  type        = string
  default     = "10.203.3.60"  # Available IP in your homelab range
}

variable "tailscale_ip" {
  description = "Tailscale IP for external access (update after deployment)"
  type        = string
  default     = ""  # Will be assigned when Tailscale joins
}

variable "gateway_ip" {
  description = "Network gateway IP"
  type        = string
  default     = "10.203.3.1"
}

variable "dns_servers" {
  description = "DNS servers (your rseau DNS server)"
  type        = string
  default     = "10.203.1.3"  # Your Technitium DNS server on rseau
}

# Cloudflare Configuration
variable "cloudflare_api_token" {
  description = "Cloudflare API token for doofus.co"
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID for doofus.co"
  type        = string
  sensitive   = true
}

# SSH Configuration
variable "ssh_public_key" {
  description = "SSH public key for access (from 1Password)"
  type        = string
  # Get from: ssh-add -L
}

# Domain Configuration
variable "domain" {
  description = "Primary domain"
  type        = string
  default     = "doofus.co"
}

# Tailscale Configuration
variable "tailscale_auth_key" {
  description = "Tailscale auth key for auto-joining tailnet"
  type        = string
  sensitive   = true
}

# Service Configuration
variable "gitlab_external_url" {
  description = "External URL for GitLab"
  type        = string
  default     = "https://gitlab.doofus.co"
}

variable "enable_gitlab_ci" {
  description = "Enable GitLab CI/CD runners"
  type        = bool
  default     = true
}

variable "gitlab_runner_registration_token" {
  description = "GitLab runner registration token"
  type        = string
  sensitive   = true
  default     = ""  # Set after GitLab is running
}