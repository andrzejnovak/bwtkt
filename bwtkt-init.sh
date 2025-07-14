#!/usr/bin/env bash
# Bitwarden Toolkit Initialization Script
# This file is sourced from ~/.bashrc to load all bwtkt functionality

# Get the directory where bwtkt is installed
BWTKT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

# Source local configuration if it exists
if [[ -f "$BWTKT_DIR/.bwtkt-config" ]]; then
    source "$BWTKT_DIR/.bwtkt-config"
fi

# Load the Bitwarden session wrapper functions
if [[ -f "$BWTKT_DIR/bw-functions.sh" ]]; then
    source "$BWTKT_DIR/bw-functions.sh"
else
    echo "Warning: bwtkt session wrapper not found at $BWTKT_DIR/bw-functions.sh"
fi

# Add bwtkt utilities to PATH if not already there
if [[ ":$PATH:" != *":$BWTKT_DIR/bin:"* ]]; then
    export PATH="$BWTKT_DIR/bin:$PATH"
fi

# Set up bwtkt environment variables
export BWTKT_DIR
export BWTKT_VERSION="0.1.0"

# Optional: Set up completion (if we add it later)
# if [[ -f "$BWTKT_DIR/completion/bwtkt-completion.bash" ]]; then
#     source "$BWTKT_DIR/completion/bwtkt-completion.bash"
# fi
