#!/usr/bin/env bash
# Bitwarden Toolkit (bwtkt) - Complete Setup Script
# This script sets up both the SSH auto-login and session wrapper functionality

set -e  # Exit on any error

BWTKT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
BASHRC_FILE="$HOME/.bashrc"
BWTKT_LINE="source \"$BWTKT_DIR/bwtkt-init.sh\""

echo "=== Bitwarden Toolkit Setup ==="
echo "Installation directory: $BWTKT_DIR"
echo

# Check if bw CLI is installed
check_bw_cli() {
    if ! command -v bw &> /dev/null; then
        echo "❌ Bitwarden CLI (bw) is not installed!"
        echo "Please install it from: https://github.com/bitwarden/cli"
        echo
        echo "Quick install options:"
        echo "  npm install -g @bitwarden/cli"
        echo "  Or download from GitHub releases"
        exit 1
    else
        echo "✅ Bitwarden CLI found: $(which bw)"
    fi
}

# Check if expect is installed (required for bwssh)
check_expect() {
    if ! command -v expect &> /dev/null; then
        echo "❌ expect is not installed (required for SSH auto-login)!"
        echo "Please install it:"
        echo "  Ubuntu/Debian: sudo apt-get install expect"
        echo "  RHEL/CentOS:   sudo yum install expect"
        echo "  macOS:         brew install expect"
        exit 1
    else
        echo "✅ expect found: $(which expect)"
    fi
}

# Make scripts executable
setup_permissions() {
    echo "🔧 Setting up file permissions..."
    chmod +x "$BWTKT_DIR/bitwarden-ssh-auto-login/bwssh"
    chmod +x "$BWTKT_DIR/bitwarden-session-wrapper/bw-functions.sh"
    chmod +x "$BWTKT_DIR/bitwarden-session-wrapper/setup.sh"
    chmod +x "$BWTKT_DIR/bwtkt-init.sh"
    echo "✅ Permissions set"
}

# Setup .bwssh config file if it doesn't exist
setup_bwssh_config() {
    if [[ ! -f "$HOME/.bwssh" ]]; then
        echo "📝 Creating example .bwssh configuration file..."
        cat > "$HOME/.bwssh" << 'EOF'
# Bitwarden SSH Auto-Login Configuration
# Format: hostname,bitwarden-object-id
# 
# Examples:
# myserver.example.com,12345678-1234-1234-1234-123456789abc
# 192.168.1.100,87654321-4321-4321-4321-abcdef123456
#
# To get object IDs, use: bw list items --search "hostname"
# 
# Lines starting with # are comments and will be ignored
EOF
        echo "✅ Created ~/.bwssh configuration file"
        echo "   Please edit ~/.bwssh to add your server configurations"
    else
        echo "✅ ~/.bwssh configuration file already exists"
    fi
}

# Add to bashrc if not already present
setup_bashrc_integration() {
    if grep -Fxq "$BWTKT_LINE" "$BASHRC_FILE" 2>/dev/null; then
        echo "✅ Already integrated with ~/.bashrc"
        return 0
    fi

    echo "🔗 Adding bwtkt integration to ~/.bashrc..."
    
    # Backup bashrc
    cp "$BASHRC_FILE" "$BASHRC_FILE.bak.$(date +%Y%m%d_%H%M%S)"
    echo "   (Backup created: ~/.bashrc.bak.*)"
    
    # Add integration line
    echo "" >> "$BASHRC_FILE"
    echo "# Bitwarden Toolkit Integration" >> "$BASHRC_FILE"
    echo "$BWTKT_LINE" >> "$BASHRC_FILE"
    
    echo "✅ Integration added to ~/.bashrc"
}

# Prompt for Bitwarden username
setup_bw_user() {
    current_user="${BW_USER:-}"
    if [[ -z "$current_user" ]]; then
        read -p "Enter your Bitwarden username/email: " bw_username
        if [[ -n "$bw_username" ]]; then
            # Add to a local config file that will be sourced
            echo "export BW_USER='$bw_username'" > "$BWTKT_DIR/.bwtkt-config"
            echo "✅ Bitwarden username configured: $bw_username"
        fi
    else
        echo "✅ Bitwarden username already configured: $current_user"
    fi
}

# Main setup flow
main() {
    echo "Checking prerequisites..."
    check_bw_cli
    check_expect
    echo

    echo "Setting up bwtkt..."
    setup_permissions
    setup_bwssh_config
    setup_bw_user
    echo

    echo "Integrating with shell..."
    setup_bashrc_integration
    echo

    echo "=== Setup Complete! ==="
    echo
    echo "Next steps:"
    echo "1. Edit ~/.bwssh to configure your servers and Bitwarden object IDs"
    echo "2. Restart your terminal or run: source ~/.bashrc"
    echo "3. Login to Bitwarden: bw --regenerate-session-key"
    echo "4. Test SSH auto-login: ssh your-configured-server"
    echo
    echo "Available commands after setup:"
    echo "  ssh <hostname>  - SSH with automatic Bitwarden credential lookup"
    echo "  scp <args>      - SCP with automatic Bitwarden credential lookup"
    echo "  bw <args>       - Enhanced Bitwarden CLI with session management"
    echo
    echo "Configuration files:"
    echo "  ~/.bwssh        - SSH server and Bitwarden object ID mappings"
    echo "  ~/.bashrc       - Shell integration (automatically added)"
    echo
}

# Allow script to be sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
