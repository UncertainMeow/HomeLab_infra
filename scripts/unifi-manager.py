#!/usr/bin/env python3
"""
UniFi Dream Machine Pro Management Tool
Manage static IPs, hostnames, ARP tables, and network settings via CSV/terminal
"""

import requests
import json
import csv
import sys
import argparse
from typing import Dict, List, Optional
import urllib3
from getpass import getpass
import pandas as pd
from datetime import datetime

# Disable SSL warnings for local UniFi controller
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

class UniFiManager:
    def __init__(self, controller_url: str, username: str = "admin", verify_ssl: bool = False):
        self.base_url = controller_url.rstrip('/')
        self.username = username
        self.password = None
        self.verify_ssl = verify_ssl
        self.session = requests.Session()
        self.session.verify = verify_ssl
        
        # Common headers
        self.session.headers.update({
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        })
        
    def login(self, password: str = None) -> bool:
        """Login to UniFi Controller"""
        if password:
            self.password = password
        else:
            self.password = getpass("UniFi Controller Password: ")
            
        login_data = {
            'username': self.username,
            'password': self.password,
            'remember': True
        }
        
        try:
            # UniFi OS login endpoint
            response = self.session.post(
                f"{self.base_url}/api/auth/login",
                json=login_data,
                verify=self.verify_ssl
            )
            
            if response.status_code == 200:
                print("✅ Successfully logged into UniFi Controller")
                return True
            else:
                print(f"❌ Login failed: {response.status_code} - {response.text}")
                return False
                
        except Exception as e:
            print(f"❌ Login error: {e}")
            return False
    
    def get_sites(self) -> List[Dict]:
        """Get all sites"""
        try:
            response = self.session.get(f"{self.base_url}/proxy/network/api/self/sites")
            if response.status_code == 200:
                return response.json().get('data', [])
            return []
        except Exception as e:
            print(f"Error getting sites: {e}")
            return []
    
    def get_clients(self, site_id: str = "default") -> List[Dict]:
        """Get all clients (devices) from a site"""
        try:
            response = self.session.get(
                f"{self.base_url}/proxy/network/api/s/{site_id}/stat/sta"
            )
            if response.status_code == 200:
                return response.json().get('data', [])
            return []
        except Exception as e:
            print(f"Error getting clients: {e}")
            return []
    
    def get_static_routes(self, site_id: str = "default") -> List[Dict]:
        """Get static routes and reservations"""
        try:
            response = self.session.get(
                f"{self.base_url}/proxy/network/api/s/{site_id}/rest/routing"
            )
            if response.status_code == 200:
                return response.json().get('data', [])
            return []
        except Exception as e:
            print(f"Error getting static routes: {e}")
            return []
    
    def get_user_groups(self, site_id: str = "default") -> List[Dict]:
        """Get user groups (for static IP assignments)"""
        try:
            response = self.session.get(
                f"{self.base_url}/proxy/network/api/s/{site_id}/rest/usergroup"
            )
            if response.status_code == 200:
                return response.json().get('data', [])
            return []
        except Exception as e:
            print(f"Error getting user groups: {e}")
            return []
    
    def set_static_ip(self, client_mac: str, ip_address: str, hostname: str = "", site_id: str = "default") -> bool:
        """Set static IP for a client"""
        try:
            # First, find the client
            clients = self.get_clients(site_id)
            client = None
            for c in clients:
                if c.get('mac', '').lower() == client_mac.lower():
                    client = c
                    break
            
            if not client:
                print(f"❌ Client with MAC {client_mac} not found")
                return False
            
            # Update client with static IP
            update_data = {
                'mac': client_mac,
                'use_fixedip': True,
                'fixed_ip': ip_address
            }
            
            if hostname:
                update_data['name'] = hostname
            
            response = self.session.put(
                f"{self.base_url}/proxy/network/api/s/{site_id}/rest/user/{client['_id']}",
                json=update_data
            )
            
            if response.status_code == 200:
                print(f"✅ Static IP {ip_address} set for {client_mac}")
                return True
            else:
                print(f"❌ Failed to set static IP: {response.status_code}")
                return False
                
        except Exception as e:
            print(f"Error setting static IP: {e}")
            return False
    
    def clear_arp_table(self, site_id: str = "default") -> bool:
        """Clear ARP table (force refresh)"""
        try:
            response = self.session.post(
                f"{self.base_url}/proxy/network/api/s/{site_id}/cmd/devmgr",
                json={'cmd': 'force-provision'}
            )
            
            if response.status_code == 200:
                print("✅ ARP table refresh initiated")
                return True
            else:
                print(f"❌ Failed to clear ARP table: {response.status_code}")
                return False
                
        except Exception as e:
            print(f"Error clearing ARP table: {e}")
            return False
    
    def export_clients_to_csv(self, filename: str = "unifi_clients.csv", site_id: str = "default"):
        """Export all clients to CSV for easy editing"""
        clients = self.get_clients(site_id)
        
        # Prepare data for CSV
        csv_data = []
        for client in clients:
            csv_data.append({
                'MAC': client.get('mac', ''),
                'Hostname': client.get('name', client.get('hostname', '')),
                'IP_Address': client.get('ip', ''),
                'Static_IP': client.get('fixed_ip', ''),
                'Use_Static': client.get('use_fixedip', False),
                'Network': client.get('network', ''),
                'First_Seen': client.get('first_seen', ''),
                'Last_Seen': client.get('last_seen', ''),
                'Vendor': client.get('oui', ''),
                'Device_Type': client.get('dev_cat', ''),
                'Signal': client.get('signal', ''),
                'Connected': client.get('is_online', False)
            })
        
        # Write to CSV
        df = pd.DataFrame(csv_data)
        df.to_csv(filename, index=False)
        print(f"✅ Exported {len(csv_data)} clients to {filename}")
        print(f"📝 Edit the CSV file and use 'import-csv' to apply changes")
    
    def import_clients_from_csv(self, filename: str, site_id: str = "default"):
        """Import client settings from CSV"""
        try:
            df = pd.read_csv(filename)
            
            success_count = 0
            for _, row in df.iterrows():
                if pd.notna(row.get('Static_IP')) and row.get('Use_Static'):
                    mac = row['MAC']
                    static_ip = row['Static_IP']
                    hostname = row.get('Hostname', '')
                    
                    if self.set_static_ip(mac, static_ip, hostname, site_id):
                        success_count += 1
            
            print(f"✅ Successfully updated {success_count} clients from CSV")
            
        except Exception as e:
            print(f"❌ Error importing from CSV: {e}")
    
    def bulk_hostname_update(self, hostname_map: Dict[str, str], site_id: str = "default"):
        """Bulk update hostnames using MAC -> hostname mapping"""
        clients = self.get_clients(site_id)
        
        success_count = 0
        for client in clients:
            client_mac = client.get('mac', '').lower()
            if client_mac in hostname_map:
                new_hostname = hostname_map[client_mac]
                
                try:
                    update_data = {'name': new_hostname}
                    response = self.session.put(
                        f"{self.base_url}/proxy/network/api/s/{site_id}/rest/user/{client['_id']}",
                        json=update_data
                    )
                    
                    if response.status_code == 200:
                        print(f"✅ Updated hostname for {client_mac} to {new_hostname}")
                        success_count += 1
                    
                except Exception as e:
                    print(f"❌ Failed to update {client_mac}: {e}")
        
        print(f"✅ Successfully updated {success_count} hostnames")
    
    def generate_static_ip_template(self, filename: str = "static_ip_template.csv"):
        """Generate a template CSV for static IP assignments"""
        template_data = [
            {
                'MAC': 'aa:bb:cc:dd:ee:ff',
                'Hostname': 'example-device',
                'Static_IP': '192.168.1.100',
                'Use_Static': True,
                'Notes': 'Example entry - replace with your devices'
            }
        ]
        
        df = pd.DataFrame(template_data)
        df.to_csv(filename, index=False)
        print(f"✅ Created template file: {filename}")
        print(f"📝 Fill in your device details and use 'import-csv' to apply")

def main():
    parser = argparse.ArgumentParser(description='UniFi Dream Machine Pro Management Tool')
    parser.add_argument('--controller', default='https://192.168.1.1', 
                       help='UniFi Controller URL (default: https://192.168.1.1)')
    parser.add_argument('--username', default='admin', 
                       help='Username (default: admin)')
    
    subparsers = parser.add_subparsers(dest='command', help='Available commands')
    
    # List clients
    subparsers.add_parser('list-clients', help='List all clients')
    
    # Export to CSV
    export_parser = subparsers.add_parser('export-csv', help='Export clients to CSV')
    export_parser.add_argument('--file', default='unifi_clients.csv', help='Output CSV file')
    
    # Import from CSV
    import_parser = subparsers.add_parser('import-csv', help='Import client settings from CSV')
    import_parser.add_argument('--file', required=True, help='Input CSV file')
    
    # Set static IP
    static_parser = subparsers.add_parser('set-static-ip', help='Set static IP for device')
    static_parser.add_argument('--mac', required=True, help='MAC address')
    static_parser.add_argument('--ip', required=True, help='Static IP address')
    static_parser.add_argument('--hostname', help='Device hostname')
    
    # Clear ARP
    subparsers.add_parser('clear-arp', help='Clear/refresh ARP table')
    
    # Generate template
    template_parser = subparsers.add_parser('generate-template', help='Generate CSV template')
    template_parser.add_argument('--file', default='static_ip_template.csv', help='Template file name')
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        return
    
    # Initialize UniFi manager
    unifi = UniFiManager(args.controller, args.username)
    
    # Login
    if not unifi.login():
        print("❌ Failed to login to UniFi Controller")
        return
    
    # Execute command
    if args.command == 'list-clients':
        clients = unifi.get_clients()
        print(f"\n📱 Found {len(clients)} clients:\n")
        for client in clients:
            status = "🟢 Online" if client.get('is_online') else "🔴 Offline"
            static = f" (Static: {client.get('fixed_ip')})" if client.get('use_fixedip') else ""
            print(f"{status} {client.get('mac', 'N/A')} - {client.get('name', 'Unnamed')} - {client.get('ip', 'No IP')}{static}")
    
    elif args.command == 'export-csv':
        unifi.export_clients_to_csv(args.file)
    
    elif args.command == 'import-csv':
        unifi.import_clients_from_csv(args.file)
    
    elif args.command == 'set-static-ip':
        unifi.set_static_ip(args.mac, args.ip, args.hostname or "")
    
    elif args.command == 'clear-arp':
        unifi.clear_arp_table()
    
    elif args.command == 'generate-template':
        unifi.generate_static_ip_template(args.file)

if __name__ == "__main__":
    main()