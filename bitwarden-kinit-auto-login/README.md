# binit — Bitwarden-backed kinit

A thin wrapper around `kinit` (MIT krb5) that fetches your Kerberos password
from Bitwarden and feeds it to the password prompt — the Kerberos companion
to the `bwssh` wrapper in [bitwarden-ssh-auto-login](../bitwarden-ssh-auto-login).

```bash
binit                     # default principal from ~/.binit (or ticket cache)
binit anovak@CERN.CH      # explicit principal
binit -l 7d -r 30d anovak@CERN.CH   # all kinit options pass through
```

## How it works

1. The principal is taken from the command line (last non-option argument),
   or the `default` entry in `~/.binit`, or the current ticket cache.
2. The principal is matched (case-insensitive substring) against `~/.binit`
   to find the Bitwarden object ID holding the password.
3. The password is fetched via the session-managed `bw()` wrapper from
   bwtkt (sourced from `~/.config/bwtkt/bwtkt-user-init.sh`), with automatic
   session regeneration on expiry — falling back to the raw `bw` CLI.
4. The password is piped to `kinit` on stdin (MIT kinit reads it from a
   pipe; the password never appears in the process list or on disk).

If no config entry matches, binit execs plain interactive `kinit` with your
original arguments, so it is always safe to use.

## Setup

Sourcing `bwtkt-functions.sh` (done by the standard bwtkt init script) puts
this directory on `PATH`, so `binit` is available directly. Alternatively:

```bash
ln -s /path/to/bwtkt/bitwarden-kinit-auto-login/binit ~/.local/bin/binit
```

Create `~/.binit`:

```
# <principal-pattern>  <bitwarden-object-id>
default  anovak@CERN.CH
CERN.CH  12345678-1234-1234-1234-123456789abc
```

Find object IDs with:

```bash
bw list items --search "cern" | jq '.[] | {name, id}'
```

## Environment overrides

| Variable       | Default                                   | Purpose                     |
| -------------- | ----------------------------------------- | --------------------------- |
| `BINIT_CONFIG` | `~/.binit`                                | config file                 |
| `BINIT_KINIT`  | `kinit` from `PATH`                       | kinit binary                |
| `BWTKT_INIT`   | `~/.config/bwtkt/bwtkt-user-init.sh`      | bwtkt session wrapper       |

## Dependencies

- MIT krb5 `kinit` (Heimdal untested; it wants `--password-file=STDIN` instead)
- `bw` (Bitwarden CLI)
- [bwtkt](../README.md) session management (`bwtkt-functions.sh`, sourced automatically)
