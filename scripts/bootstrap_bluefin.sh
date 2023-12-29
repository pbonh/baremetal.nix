#!/usr/bin/env bash
#
# README ======================================
#  # Run FIRST
#  ```
#  just devmode
#  refresh-global
#  systemctl reboot
#  ```
# =============================================

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install Nix
if ! command_exists nix; then
    just nix-install
    refresh-global
fi

# Install Devbox
if ! command_exists devbox; then
    just devbox-install
    refresh-global
    just nix-devbox
    refresh-global
    just nix-devbox-global
    refresh-global
fi

# Install Fleek
if ! command_exists fleek; then
    just fleek-install
    refresh-global
fi

# Function to ensure necessary commands are available
ensure_commands() {
    local missing_cmds=()

    # Check for git and ghq
    if ! command_exists nix; then
        missing_cmds+=("nix")
    fi
    if ! command_exists devbox; then
        missing_cmds+=("devbox")
    fi
    if ! command_exists fleek; then
        missing_cmds+=("fleek")
    fi

    # Handle missing commands
    if [ ${#missing_cmds[@]} -ne 0 ]; then
        echo "The following commands are not available but are required: ${missing_cmds[*]}"
        echo "Please install them and rerun the script."
        exit 1
    fi
}

# Check if necessary commands are available
ensure_commands

# Function to setup Bash
setup_bashrc() {
    # Define the directory and file path
    bashrc_d_dir="$HOME/.bashrc.d"
    bluefin_file="$bashrc_d_dir/bluefin"
    
    # Create the ~/.bashrc.d directory if it does not exist
    if [[ ! -d "$bashrc_d_dir" ]]; then
        mkdir -p "$bashrc_d_dir"
        echo "Created directory: $bashrc_d_dir"
    fi
    
    # Create and populate the bluefin file if it does not exist
    if [[ ! -f "$bluefin_file" ]]; then
        cat <<-EOF > "$bluefin_file"
	# Add nix to PATH manually
        export PATH=\$PATH:/nix/var/nix/profiles/default/bin
	# Source Devbox Global
        eval "\$(devbox global shellenv --init-hook)"
EOF
        echo "Created and initialized file: $bluefin_file"
    else
        echo "File already exists: $bluefin_file"
    fi
}

setup_bashrc
