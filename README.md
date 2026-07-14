# BWTKT - Bitwarden Toolkit

A Bitwarden CLI session management and SSH auto-login integration toolkit.

## Features

- **Automatic session management**: Seamlessly handles Bitwarden CLI session creation and renewal
- **SSH auto-login**: Automatically inject credentials for SSH connections
- **Kerberos auto-login**: `binit` wraps `kinit` and auto-fills the password from Bitwarden
- **Error recovery**: Automatically regenerates sessions when expired or invalid
- **`bwtkt` CLI**: `bwtkt list` / `bwtkt add` / `bwtkt doctor` to manage host and principal mappings

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
├── bwtkt-functions.sh           # Bitwarden wrapper functions (session management)
├── bwtkt-ui.sh                  # Shared terminal UI helpers (colors, prompts)
├── setup.sh                     # Interactive setup script for new users
├── bin/
│   └── bwtkt                    # Management CLI: list / add / doctor
├── bitwarden-ssh-auto-login/    # SSH auto-login components
│   ├── bwssh                    # SSH wrapper script
│   └── bwssh.expect             # Expect script for credential injection
├── bitwarden-kinit-auto-login/  # Kerberos auto-login components
│   ├── binit                    # kinit wrapper script (see its README)
│   └── README.md
└── README.md                    # This file

User files (created by setup):
~/.config/bwtkt/bwtkt-user-init.sh  # User-specific configuration and sourcing
~/.bwssh                            # SSH host mappings (optional)
~/.binit                            # Kerberos principal mappings (optional)
```

## Configuration

### SSH Auto-login Setup

If you want SSH auto-login functionality, create `~/.bwssh` with entries in the format
(whitespace- or comma-separated; `#` comments allowed):
```
<host-pattern>  <bitwarden-object-id>  [label...]
```

Example:
```
lxplus.cern.ch   12345678-1234-1234-1234-123456789abc  CERN
!dev.example.com a1b2c3d4-e5f6-7890-abcd-ef1234567890  dev box
```

Patterns are matched as substrings of the destination host only. A `!` prefix
skips the confirmation prompt for that host. The optional label is shown in
prompts instead of the raw object ID.

### Managing entries

The smoothest way is doing nothing: the first time you `ssh` a host that has
no config entry (on a terminal), bwssh offers — once per host, ever — to link
it to a vault item on the spot, then autofills that same connection. Declined
hosts are remembered in `~/.cache/bwtkt/offered-hosts` and never asked about
again; delete a line there to be asked once more.

Or use the `bwtkt` CLI directly (needs `jq`; picking uses `fzf` when
installed, a numbered list otherwise — a single search hit just confirms):
```bash
bwtkt list                    # show all configured hosts and principals
bwtkt add lxplus.cern.ch      # map an ssh host to a vault item
bwtkt add myhost cern         # second argument seeds the vault search
bwtkt add -k CERN.CH          # map a kerberos principal (for binit)
bwtkt doctor                  # sanity-check the installation
```
`BWTKT_ASSUME_YES=1` answers confirmation prompts automatically (scripting).

Or find object IDs by hand:
```bash
bw list items --search "server" | jq '.[] | {name, id}'
```

## Usage

### Basic Commands

```bash
# Regenerate Bitwarden session (if needed)
bw relogin

# SSH with auto-login (if configured in ~/.bwssh)
ssh user@hostname

# SCP with auto-login (if configured)
scp file.txt user@hostname:/path/

# Kerberos ticket with auto-filled password (if configured in ~/.binit)
binit                    # default principal
binit user@REALM.ORG     # explicit principal; kinit options pass through
```

Connections to hosts without a config entry behave exactly like plain
`ssh`/`scp` — the wrapper stays silent. Logins that succeed without a
password prompt (Kerberos/GSSAPI ticket, public key) are handed over
untouched.

### Session Management and Security Notes

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
