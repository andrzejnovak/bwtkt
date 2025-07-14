# BWTKT - Bitwarden Toolkit

A Bitwarden CLI session management and SSH auto-login integration toolkit.

## Features

- **Automatic session management**: Seamlessly handles Bitwarden CLI session creation and renewal
- **SSH auto-login**: Automatically inject credentials for SSH connections
- **Error recovery**: Automatically regenerates sessions when expired or invalid

## Installation

### Automatic Setup (Recommended)

1. Clone this repository:
   ```bash
   git clone <repository-url> /path/to/bwtkt
   cd /path/to/bwtkt
   ```

2. Run the setup script:
   ```bash
   ./setup.sh
   ```

3. The setup will:
   - Prompt for your Bitwarden username/email
   - Create user-specific configuration in `~/.config/bwtkt/`
   - Link integration in your `~/.bashrc` (with confirmation)
   - Configure SSH auto-login settings

4. Restart your shell or run `source ~/.bashrc` to activate

### Manual Setup

If you prefer manual configuration or the setup script doesn't work:

1. Clone the repository:
   ```bash
   git clone <repository-url> /path/to/bwtkt
   ```

2. Add the following to your `~/.bashrc` (replace `/path/to/bwtkt` with actual path):
   ```bash
   # BWTKT (Bitwarden Toolkit) Integration
   export BW_USER="your-email@example.com"
   source /path/to/bwtkt/bw-functions.sh
   export PATH="/path/to/bwtkt/bitwarden-ssh-auto-login:$PATH"
   ```

3. Restart your shell or run `source ~/.bashrc`

4. (Optional) Configure SSH hosts in `~/.bwssh` (see Configuration section)

## Structure

```
bwtkt/
├── bw-functions.sh            # Bitwarden wrapper functions (session management)
├── setup.sh                   # Interactive setup script for new users
├── bitwarden-ssh-auto-login/  # SSH auto-login components
│   ├── bwssh                  # SSH wrapper script
│   └── bwssh.expect           # Expect script for credential injection
└── README.md                  # This file

User files (created by setup):
~/.config/bwtkt/bwtkt-user-init.sh  # User-specific configuration and sourcing
~/.bwssh                            # SSH host mappings (optional)
```

## Configuration

### SSH Auto-login Setup

If you want SSH auto-login functionality, create `~/.bwssh` with entries in the format:
```
hostname,bitwarden-object-id
```

Example:
```
lxplus.cern.ch,d61247ce-233f-43a6-8b4f-acdd0160bd82
server.example.com,a1b2c3d4-e5f6-7890-abcd-ef1234567890
```

### Finding Bitwarden Object IDs

To find the object IDs for your SSH credentials:
```bash
# Search for items and show clean name/ID output
bw list items --search "server" | jq '.[] | {name, id}'

# Get a specific item's details
bw get item "server-name"
```

## Usage

### Basic Commands

```bash
# Regenerate Bitwarden session (if needed)
bw --regenerate-session-key

# SSH with auto-login (if configured in ~/.bwssh)
ssh user@hostname

# SCP with auto-login (if configured)
scp file.txt user@hostname:/path/
```

### Session Management and Securit Notes

The toolkit automatically:
- Creates session files in `/var/root/.bitwarden.session` (root access only)
- Sudo cache is cleared after operations
- Interactive prompts work correctly (no credential exposure in logs)
- Session regeneration requires master password confirmation

### Re-running Setup

The setup script can be run multiple times safely:
- It detects existing configurations
- Prompts before making changes  
- Allows you to update settings incrementally

## Dependencies

- `bw` (Bitwarden CLI) - Install from [bitwarden.com/download](https://bitwarden.com/download/)
- `expect` (for SSH automation) - Usually available via package manager
- `jq` (optional, for JSON processing in examples)
