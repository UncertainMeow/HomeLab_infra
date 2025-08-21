#!/bin/bash
# UniFi Dream Machine Pro Bulk Operations Helper
# Makes common network management tasks easier

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UNIFI_SCRIPT="$SCRIPT_DIR/unifi-manager.py"

# Default UniFi controller (update with your UDM Pro IP)
CONTROLLER_URL="${UNIFI_CONTROLLER:-https://192.168.1.1}"

echo "🛜 UniFi Dream Machine Pro Bulk Operations"
echo "========================================="

# Check if Python dependencies are available
check_dependencies() {
    echo "📋 Checking dependencies..."
    
    if ! python3 -c "import requests, pandas" 2>/dev/null; then
        echo "❌ Missing Python dependencies. Installing..."
        pip3 install requests pandas urllib3
    fi
    
    echo "✅ Dependencies ready"
}

# Interactive menu
show_menu() {
    echo ""
    echo "🎯 Available Operations:"
    echo "1) List all devices"
    echo "2) Export devices to CSV for editing"
    echo "3) Import changes from CSV"
    echo "4) Set static IP for single device"
    echo "5) Clear/refresh ARP table"
    echo "6) Generate CSV template"
    echo "7) Backup current config"
    echo "8) Batch hostname updates"
    echo "9) Find devices by vendor"
    echo "0) Exit"
    echo ""
}

# Backup current configuration
backup_config() {
    timestamp=$(date +%Y%m%d_%H%M%S)
    backup_file="unifi_backup_$timestamp.csv"
    
    echo "💾 Creating backup: $backup_file"
    python3 "$UNIFI_SCRIPT" --controller "$CONTROLLER_URL" export-csv --file "$backup_file"
    echo "✅ Backup saved to $backup_file"
}

# Interactive static IP assignment
interactive_static_ip() {
    echo "📝 Interactive Static IP Assignment"
    echo "=================================="
    
    # List current devices first
    python3 "$UNIFI_SCRIPT" --controller "$CONTROLLER_URL" list-clients
    
    echo ""
    read -p "Enter MAC address (e.g., aa:bb:cc:dd:ee:ff): " mac
    read -p "Enter static IP address: " ip
    read -p "Enter hostname (optional): " hostname
    
    python3 "$UNIFI_SCRIPT" --controller "$CONTROLLER_URL" set-static-ip --mac "$mac" --ip "$ip" --hostname "$hostname"
}

# Batch operations from CSV
batch_operations() {
    echo "📊 CSV-Based Batch Operations"
    echo "============================"
    
    # Check if there are existing CSV files
    csv_files=(*.csv)
    if [ ${#csv_files[@]} -gt 0 ] && [ -e "${csv_files[0]}" ]; then
        echo "📄 Found existing CSV files:"
        ls -la *.csv | grep -v "^d"
        echo ""
    fi
    
    echo "Options:"
    echo "1) Create new export"
    echo "2) Use existing CSV file"
    read -p "Choice: " choice
    
    case $choice in
        1)
            timestamp=$(date +%Y%m%d_%H%M%S)
            csv_file="unifi_devices_$timestamp.csv"
            python3 "$UNIFI_SCRIPT" --controller "$CONTROLLER_URL" export-csv --file "$csv_file"
            echo ""
            echo "📝 Next steps:"
            echo "1. Open $csv_file in Excel/Numbers/Text editor"
            echo "2. Edit the 'Static_IP', 'Hostname', and 'Use_Static' columns"
            echo "3. Save the file"
            echo "4. Run this script again and choose option 2"
            ;;
        2)
            read -p "Enter CSV filename: " csv_file
            if [ -f "$csv_file" ]; then
                python3 "$UNIFI_SCRIPT" --controller "$CONTROLLER_URL" import-csv --file "$csv_file"
            else
                echo "❌ File not found: $csv_file"
            fi
            ;;
    esac
}

# Main interactive loop
main() {
    check_dependencies
    
    echo ""
    echo "🏠 Controller: $CONTROLLER_URL"
    echo "📝 Tip: Update UNIFI_CONTROLLER environment variable if needed"
    
    while true; do
        show_menu
        read -p "Select operation (0-9): " choice
        
        case $choice in
            1)
                python3 "$UNIFI_SCRIPT" --controller "$CONTROLLER_URL" list-clients
                ;;
            2)
                timestamp=$(date +%Y%m%d_%H%M%S)
                csv_file="unifi_export_$timestamp.csv"
                python3 "$UNIFI_SCRIPT" --controller "$CONTROLLER_URL" export-csv --file "$csv_file"
                echo "📝 Edit $csv_file and use option 3 to import changes"
                ;;
            3)
                batch_operations
                ;;
            4)
                interactive_static_ip
                ;;
            5)
                python3 "$UNIFI_SCRIPT" --controller "$CONTROLLER_URL" clear-arp
                ;;
            6)
                python3 "$UNIFI_SCRIPT" --controller "$CONTROLLER_URL" generate-template
                ;;
            7)
                backup_config
                ;;
            8)
                echo "📝 Batch hostname updates - use CSV export/import for now"
                ;;
            9)
                echo "🔍 Device search - use CSV export and filter for now"
                ;;
            0)
                echo "👋 Goodbye!"
                exit 0
                ;;
            *)
                echo "❌ Invalid choice. Please select 0-9."
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

# Handle command line arguments
if [ $# -gt 0 ]; then
    case $1 in
        "quick-export")
            check_dependencies
            timestamp=$(date +%Y%m%d_%H%M%S)
            python3 "$UNIFI_SCRIPT" --controller "$CONTROLLER_URL" export-csv --file "unifi_quick_$timestamp.csv"
            ;;
        "quick-backup")
            check_dependencies
            backup_config
            ;;
        *)
            echo "Usage: $0 [quick-export|quick-backup]"
            echo "Or run without arguments for interactive mode"
            ;;
    esac
else
    main
fi