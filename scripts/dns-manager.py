#!/usr/bin/env python3
"""
Technitium DNS Server Management Script
Manages DNS zones and records for HomeLab infrastructure
"""

import requests
import json
import sys
from typing import Dict, List, Optional

class TechnitiumDNS:
    def __init__(self, base_url: str = "http://10.203.1.3:5380", username: str = "admin"):
        self.base_url = base_url
        self.username = username
        self.token = None
        self.session = requests.Session()
        
    def login(self, password: str) -> bool:
        """Authenticate with Technitium DNS"""
        try:
            response = self.session.post(f"{self.base_url}/api/user/login", data={
                'user': self.username,
                'pass': password
            })
            result = response.json()
            
            if result.get('status') == 'ok':
                self.token = result.get('token')
                return True
            else:
                print(f"Login failed: {result.get('errorMessage', 'Unknown error')}")
                return False
        except Exception as e:
            print(f"Login error: {e}")
            return False
    
    def list_zones(self) -> List[Dict]:
        """List all DNS zones"""
        if not self.token:
            return []
            
        try:
            response = self.session.get(f"{self.base_url}/api/zones/list", params={
                'token': self.token
            })
            result = response.json()
            
            if result.get('status') == 'ok':
                return result.get('zones', [])
            else:
                print(f"Error listing zones: {result.get('errorMessage')}")
                return []
        except Exception as e:
            print(f"Error listing zones: {e}")
            return []
    
    def create_zone(self, domain: str, zone_type: str = "Primary") -> bool:
        """Create a new DNS zone"""
        if not self.token:
            return False
            
        try:
            response = self.session.post(f"{self.base_url}/api/zones/create", data={
                'token': self.token,
                'zone': domain,
                'type': zone_type
            })
            result = response.json()
            
            if result.get('status') == 'ok':
                print(f"Zone '{domain}' created successfully")
                return True
            else:
                print(f"Error creating zone: {result.get('errorMessage')}")
                return False
        except Exception as e:
            print(f"Error creating zone: {e}")
            return False
    
    def add_record(self, domain: str, name: str, record_type: str, value: str, ttl: int = 3600) -> bool:
        """Add a DNS record"""
        if not self.token:
            return False
            
        try:
            data = {
                'token': self.token,
                'zone': domain,
                'name': name,
                'type': record_type,
                'ttl': ttl
            }
            
            # Add record-type specific data
            if record_type.upper() == 'A':
                data['ipAddress'] = value
            elif record_type.upper() == 'CNAME':
                data['cname'] = value
            elif record_type.upper() == 'TXT':
                data['text'] = value
            else:
                data['rdata'] = value
            
            response = self.session.post(f"{self.base_url}/api/zones/records/add", data=data)
            result = response.json()
            
            if result.get('status') == 'ok':
                print(f"Record '{name}.{domain}' ({record_type}: {value}) added successfully")
                return True
            else:
                print(f"Error adding record: {result.get('errorMessage')}")
                return False
        except Exception as e:
            print(f"Error adding record: {e}")
            return False
    
    def setup_gitlab_records(self, domain: str = "doofus.co", gitlab_ip: str = "10.203.3.60") -> bool:
        """Setup DNS records for GitLab deployment"""
        print(f"Setting up GitLab DNS records for {domain}...")
        
        # Ensure zone exists
        zones = self.list_zones()
        zone_exists = any(zone.get('name') == domain for zone in zones)
        
        if not zone_exists:
            if not self.create_zone(domain):
                return False
        
        # Add GitLab records
        records_to_add = [
            ("gitlab", "A", gitlab_ip),
            ("git", "CNAME", f"gitlab.{domain}"),
            ("registry", "CNAME", f"gitlab.{domain}"),
        ]
        
        success = True
        for name, record_type, value in records_to_add:
            if not self.add_record(domain, name, record_type, value):
                success = False
        
        return success

def main():
    """Main CLI interface"""
    if len(sys.argv) < 2:
        print("Usage: python3 dns-manager.py <command> [args...]")
        print("Commands:")
        print("  list-zones")
        print("  setup-gitlab <domain> <ip>")
        print("  add-record <domain> <name> <type> <value>")
        return
    
    # Initialize DNS client
    dns = TechnitiumDNS()
    
    # For now, use default password - will integrate with vault later
    if not dns.login("admin"):
        print("Failed to authenticate with DNS server")
        return
    
    command = sys.argv[1]
    
    if command == "list-zones":
        zones = dns.list_zones()
        print(f"\nFound {len(zones)} zones:")
        for zone in zones:
            print(f"  - {zone.get('name')} ({zone.get('type')})")
    
    elif command == "setup-gitlab":
        domain = sys.argv[2] if len(sys.argv) > 2 else "doofus.co"
        ip = sys.argv[3] if len(sys.argv) > 3 else "10.203.3.60"
        dns.setup_gitlab_records(domain, ip)
    
    elif command == "add-record":
        if len(sys.argv) < 6:
            print("Usage: add-record <domain> <name> <type> <value>")
            return
        domain, name, record_type, value = sys.argv[2:6]
        dns.add_record(domain, name, record_type, value)
    
    else:
        print(f"Unknown command: {command}")

if __name__ == "__main__":
    main()