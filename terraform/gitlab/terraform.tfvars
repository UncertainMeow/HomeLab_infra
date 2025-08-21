# Terraform configuration for GitLab IaC Services VM
# Ready for deployment on fresh Proxmox 9 rawls installation

# Proxmox Configuration
proxmox_api_url    = "https://10.203.3.47:8006/api2/json"
proxmox_user       = "root@pam"
proxmox_password   = "TempDeploy123!"
proxmox_node       = "rawls"
proxmox_storage    = "local-lvm"

# Network Configuration
iac_services_ip = "10.203.3.60"
gateway_ip      = "10.203.3.1"
dns_servers     = "10.203.1.3"  # Your Technitium DNS server

# SSH Configuration (Temporary deployment key)
ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMuJ8eulTnRe/N36HLyldwYgzq53SndQkIkD3xlIwUiG"

# Domain Configuration
domain             = "doofus.co"
gitlab_external_url = "https://gitlab.doofus.co"

# Cloudflare Configuration (Update with your values)
cloudflare_api_token = "YOUR_CLOUDFLARE_API_TOKEN"
cloudflare_zone_id   = "YOUR_CLOUDFLARE_ZONE_ID"

# Tailscale Configuration (1Password reference)
tailscale_auth_key = "op://Private/ts_gitlab_authkey/credential"

# GitLab Configuration
enable_gitlab_ci = true
gitlab_runner_registration_token = ""  # Set after GitLab is deployed