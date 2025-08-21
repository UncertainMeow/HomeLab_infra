# UniFi Dream Machine Pro Management Tools

**Finally! Terminal and CSV-based UniFi management!** 🎉

No more clicking through the UniFi interface for bulk operations. These tools let you:
- Export all devices to CSV for Excel/spreadsheet editing
- Bulk update static IPs and hostnames
- Clear ARP tables when things get stuck
- Backup configurations automatically

## 🚀 Quick Start

### Option 1: Interactive Menu (Recommended)
```bash
./scripts/unifi-bulk-operations.sh
```

### Option 2: Direct Commands
```bash
# List all devices
./scripts/unifi-manager.py list-clients

# Export to CSV for editing
./scripts/unifi-manager.py export-csv --file my_devices.csv

# Import changes from CSV
./scripts/unifi-manager.py import-csv --file my_devices.csv

# Set single static IP
./scripts/unifi-manager.py set-static-ip --mac aa:bb:cc:dd:ee:ff --ip 192.168.1.100 --hostname "my-device"

# Clear ARP table (fixes stuck/old entries)
./scripts/unifi-manager.py clear-arp
```

## 📊 CSV Workflow (Perfect for Learning!)

This is the easiest way to manage lots of devices:

### Step 1: Export Current State
```bash
./scripts/unifi-manager.py export-csv --file devices.csv
```

### Step 2: Edit in Excel/Numbers/Text Editor
Open `devices.csv` and edit these columns:
- **Hostname**: Give devices friendly names
- **Static_IP**: Set the IP you want (e.g., 192.168.1.100)
- **Use_Static**: Set to `TRUE` to enable static IP

### Step 3: Import Changes
```bash
./scripts/unifi-manager.py import-csv --file devices.csv
```

### Step 4: Clear ARP if Needed
```bash
./scripts/unifi-manager.py clear-arp
```

## 🎯 Common Use Cases

### Fix Stuck ARP Entries
Those devices showing old IPs that won't update? This fixes it:
```bash
./scripts/unifi-manager.py clear-arp
```

### Bulk Static IP Assignment
1. Export devices to CSV
2. Fill in the Static_IP column for devices you want static
3. Set Use_Static to TRUE for those devices  
4. Import the CSV back

### Hostname Cleanup
1. Export to CSV
2. Clean up device names in the Hostname column
3. Import back

### Backup Before Changes
```bash
./scripts/unifi-bulk-operations.sh quick-backup
```

## 🔧 Configuration

### Update Your UDM Pro IP
Edit the controller URL in the scripts or set environment variable:
```bash
export UNIFI_CONTROLLER="https://192.168.1.1"  # Your UDM Pro IP
```

### Install Dependencies (if needed)
```bash
pip3 install requests pandas urllib3
```

## 📋 CSV File Format

When you export, you get a CSV with these columns:

| Column | Description | Example |
|--------|-------------|---------|
| MAC | Device MAC address | aa:bb:cc:dd:ee:ff |
| Hostname | Device name | socrates |  
| IP_Address | Current IP | 192.168.1.42 |
| Static_IP | Set this for static IP | 192.168.1.100 |
| Use_Static | TRUE/FALSE | TRUE |
| Network | Network name | LAN |
| Connected | Online status | TRUE |
| Vendor | Device manufacturer | Apple |

## 🎉 Why This is Awesome

### Before (UniFi GUI):
- Click through menus for each device
- No bulk operations
- Hard to see overall picture
- ARP issues require router reboot

### After (These Tools):
- ✅ CSV export/import for bulk changes
- ✅ Terminal commands for automation  
- ✅ Easy backup and restore
- ✅ ARP table management
- ✅ Perfect for learning networking concepts

## 🔍 Troubleshooting

### "Login Failed"
- Check your UDM Pro IP address
- Verify admin username/password
- Make sure you can access the UniFi web interface

### "No Devices Found"
- Verify you're connected to the right network
- Check if devices are showing in UniFi web interface

### "CSV Import Not Working"
- Make sure MAC addresses are correct format (aa:bb:cc:dd:ee:ff)
- Verify IP addresses are in your network range
- Check that Use_Static column has TRUE/FALSE values

## 🎯 Integration with HomeLab

These tools work great with your Ansible infrastructure:

```bash
# Export UniFi devices
./scripts/unifi-manager.py export-csv --file current_devices.csv

# Use the CSV to plan static IPs for your services
# Import updated static IPs
./scripts/unifi-manager.py import-csv --file updated_devices.csv

# Update DNS records to match
python3 scripts/dns-manager.py add-record doofus.co socrates A 192.168.1.42
```

## 📚 Next Steps

1. **Try the interactive menu**: `./scripts/unifi-bulk-operations.sh`
2. **Export your current devices**: See what you're working with
3. **Practice with CSV**: Make small changes and import them
4. **Set up static IPs**: Give your servers consistent IPs
5. **Integrate with DNS**: Match your DNS records to static IPs

---

**No more UniFi interface frustration! 🎉 Terminal + CSV = Network management happiness**