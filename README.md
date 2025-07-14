# BWTKT - Bitwarden Toolkit

A robust Bitwarden CLI session management and SSH auto-login integration toolkit.

## Features

- **Automatic session management**: Seamlessly handles Bitwarden CLI session creation and renewal
- **SSH auto-login**: Automatically inject credentials for SSH connections
- **Secure credential storage**: Uses root-only accessible session files for enhanced security
- **Interactive prompts**: Properly handles master password prompts and 2FA
- **Error recovery**: Automatically regenerates sessions when expired or invalid

## Installation

1. Clone or download this repository
2. Add the following to your `~/.bashrc`:
   ```bash
   source /path/to/bwtkt/bwtkt-init.sh
   ```
3. Configure your SSH hosts in `~/.bwssh` (see Configuration section)

## Structure

```
bwtkt/
├── bw-functions.sh              # Main Bitwarden wrapper functions
├── bwtkt-init.sh               # Initialization script for .bashrc
├── bitwarden-ssh-auto-login/   # SSH auto-login components
│   ├── bwssh                   # SSH wrapper script
│   └── bwssh.expect           # Expect script for credential injection
└── README.md                   # This file
```

## Configuration

### SSH Auto-login Setup

Create `~/.bwssh` with entries in the format:
```
hostname,bitwarden-object-id
```

Example:
```
lxplus.cern.ch,d61247ce-233f-43a6-8b4f-acdd0160bd82
server.example.com,a1b2c3d4-e5f6-7890-abcd-ef1234567890
```

### Environment Variables

- `BW_USER`: Your Bitwarden email (set in bw-functions.sh)
- `BWTKT_DIR`: Auto-set to installation directory
- `BWTKT_VERSION`: Toolkit version

## Usage

### Basic Commands

```bash
# Regenerate Bitwarden session
bw --regenerate-session-key

# Use any bw command (automatically handles sessions)
bw get item <object-id>
bw list items

# SSH with auto-login (if configured)
ssh user@hostname

# SCP with auto-login (if configured)
scp file.txt user@hostname:/path/
```

### Session Management

The toolkit automatically:
- Creates session files in `/var/root/.bitwarden.session`
- Prompts for master password when needed
- Handles 2FA/TOTP automatically
- Manages sudo privileges securely
- Regenerates expired sessions

## Security Notes

- Session files are stored in `/var/root/` (root access only)
- Sudo cache is cleared after operations
- Interactive prompts work correctly (no credential exposure in logs)
- Session regeneration requires master password confirmation

## Troubleshooting

### Common Issues

1. **"Session key is invalid"**: Run `bw --regenerate-session-key`
2. **SSH hanging**: Check `~/.bwssh` configuration format
3. **Sudo loops**: Ensure proper permissions on `/var/root/`

### Debug Mode

For SSH debugging, you can check the expect script behavior:
```bash
# Enable debug in the expect script if needed
```

## Dependencies

- `bw` (Bitwarden CLI)
- `expect` (for SSH automation)
- `sudo` access for session file management

## License

This toolkit is provided as-is for personal use.
