#!/bin/bash

HOSTS_FILE="/etc/hosts"
BACKUP_HOSTS_FILE="/etc/hosts.zgubacasa_backup"
DISTRACTING_DOMAINS=(
    "facebook.com"
    "www.facebook.com"
    "twitter.com"
    "www.twitter.com"
    "instagram.com"
    "www.instagram.com"
    "reddit.com"
    "www.reddit.com"
    "youtube.com"
    "www.youtube.com"
    "tiktok.com"
    "www.tiktok.com"
)

# Function to check for root privileges
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root. Please use 'sudo'."
        exit 1
    fi
}

# Function to flush DNS cache
flush_dns_cache() {
    echo "Flushing DNS cache..."
    # Attempt to restart common DNS services to clear cache
    if command -v systemctl &> /dev/null; then
        sudo systemctl restart systemd-resolved 2>/dev/null || true
        sudo systemctl restart NetworkManager 2>/dev/null || true
    fi
    # For older systems or other DNS services
    sudo killall -HUP dnsmasq 2>/dev/null || true
    echo "DNS cache flush attempted. You might need to restart your browser for changes to take full effect."
}

# Function to start focus mode
start_focus_mode() {
    check_root
    echo "Activating ZgubaČasa Canary Focus Mode..."

    # Create a backup of the original hosts file if it doesn't exist
    if [[ ! -f "$BACKUP_HOSTS_FILE" ]]; then
        cp "$HOSTS_FILE" "$BACKUP_HOSTS_FILE"
        echo "Backup of $HOSTS_FILE created at $BACKUP_HOSTS_FILE"
    fi

    # Remove any previous ZgubaČasa entries before adding new ones to prevent duplicates
    sed -i '/# ZgubaCasa Canary BLOCK START/,/# ZgubaCasa Canary BLOCK END/d' "$HOSTS_FILE"

    echo "# ZgubaCasa Canary BLOCK START" >> "$HOSTS_FILE" # Marker for start of blocked entries
    for domain in "${DISTRACTING_DOMAINS[@]}"; do
        echo "127.0.0.1 $domain" >> "$HOSTS_FILE" # Redirect distracting domains to localhost
        echo "Blocked: $domain"
    done
    echo "# ZgubaCasa Canary BLOCK END" >> "$HOSTS_FILE" # Marker for end of blocked entries

    flush_dns_cache
    echo "ZgubaČasa Canary Focus Mode activated. Distracting sites are now blocked."
    echo "To unblock, run: sudo $0 stop"
}

# Function to stop focus mode
stop_focus_mode() {
    check_root
    echo "Deactivating ZgubaČasa Canary Focus Mode..."

    if [[ -f "$BACKUP_HOSTS_FILE" ]]; then
        cp "$BACKUP_HOSTS_FILE" "$HOSTS_FILE" # Restore hosts file from backup
        rm "$BACKUP_HOSTS_FILE" # Remove the backup file
        echo "Original $HOSTS_FILE restored from backup."
    else
        # If no backup, just remove the ZgubaCasa specific blocks
        sed -i '/# ZgubaCasa Canary BLOCK START/,/# ZgubaCasa Canary BLOCK END/d' "$HOSTS_FILE"
        echo "No backup found. ZgubaČasa Canary entries removed from $HOSTS_FILE."
    fi

    flush_dns_cache
    echo "ZgubaČasa Canary Focus Mode deactivated. Distracting sites are now accessible."
}

# Main script logic
case "$1" in
    start)
        start_focus_mode
        ;; 
    stop)
        stop_focus_mode
        ;; 
    *)
        echo "Usage: sudo $0 {start|stop}"
        echo "  start: Activates focus mode by blocking distracting websites."
        echo "  stop: Deactivates focus mode by unblocking websites."
        exit 1
        ;;
esac
