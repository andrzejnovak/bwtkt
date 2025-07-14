#!/usr/bin/env bash
# Original working Bitwarden functions from .bashrc
# Extracted without modifications

# Get the directory where this script is located
SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

alias ssh=". ${SCRIPT_DIR}/bitwarden-ssh-auto-login/bwssh ssh"
alias scp=". ${SCRIPT_DIR}/bitwarden-ssh-auto-login/bwssh scp"
export BW_USER='novak.andrzej@gmail.com'

bw() {
  bw_exec=$(sh -c "which bw")
  local -r bw_session_file='/var/root/.bitwarden.session' # Only accessible as root
  local -r bw_session_dir=$(dirname "$bw_session_file")
  
  # Make bw_session global so it persists between function calls
  # Don't declare it as local

  # Check if the session directory exists
  _check_session_directory() {
    if [ ! -d "$bw_session_dir" ]; then
      echo "Warning: Session directory '$bw_session_dir' does not exist."
      read -p "Would you like to create it? (y/N): " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        if sudo mkdir -p "$bw_session_dir"; then
          echo "Successfully created directory: $bw_session_dir"
        else
          echo "Error: Failed to create directory: $bw_session_dir"
          return 1
        fi
      else
        echo "Cannot proceed without the session directory."
        return 1
      fi
    fi
  }

  _read_token_from_file() {
    local -r err_token_not_found="Token not found, please run bw --regenerate-session-key"
    case $1 in
    '--force')
      unset bw_session
      ;;
    esac

    if [ "$bw_session" = "$err_token_not_found" ]; then
      unset bw_session
    fi

    # If the session key env variable is not set, read it from the file
    # if file it not there, ask user to regenerate it

    # Check if session directory exists before trying to read the file
    _check_session_directory || return 1

    if [ -z "$bw_session" ]; then
      # Check if session file exists
      if [ ! -f "$bw_session_file" ]; then
        return 1  # No session file, let caller handle this
      fi
      
      # Try to read the session file
      bw_session="$(sudo cat $bw_session_file 2>/dev/null)"
      local read_exit_code=$?
      # Don't clear sudo cache here - will be cleared at the end of the bw function call
      
      if [ "$read_exit_code" -ne "0" ] || [ -z "$bw_session" ]; then
        sudo -k # Clear on error
        return 1  # Couldn't read session, let caller handle this
      fi
    fi
    
    return 0  # Success
  }

  case $1 in
  '--regenerate-session-key')
    echo "Regenerating session key, this has invalidated all existing sessions..."
    
    # Check if session directory exists before trying to create the session file
    _check_session_directory || return 1
    
    sudo rm -f /var/root/.bitwarden.session && ${bw_exec} logout 2>/dev/null # Invalidate all existing sessions

    ${bw_exec} login "${BW_USER}" --raw | sudo tee /var/root/.bitwarden.session &>/dev/null # Generate new session key

    _read_token_from_file --force # Read the new session key for immediate use
    sudo -k                       # De-elevate privileges, only doing this now so _read_token_from_file can resuse the same sudo session
    ;;

  'login' | 'logout' | 'config')
    ${bw_exec} "$@"
    ;;

  '--help' | '-h' | '')
    ${bw_exec} "$@"
    echo "To regenerate your session key type:"
    echo "  bw --regenerate-session-key"
    ;;

  *)
    _read_token_from_file

    # If _read_token_from_file failed, we need to regenerate session and retry
    if [ $? -ne 0 ]; then
      echo "No valid session found. Regenerating session..."
      
      # Regenerate session first
      if bw --regenerate-session-key; then
        echo "Session regenerated successfully. Retrying command..."
        # Now retry the original command
        _read_token_from_file --force
        ${bw_exec} "$@" --session "$bw_session"
      else
        echo "Failed to regenerate session."
        return 1
      fi
    else
      # We have a valid session, run the command
      ${bw_exec} "$@" --session "$bw_session"
    fi
    
    # Clear sudo cache after all operations are complete
    sudo -k
    ;;
  esac
}
