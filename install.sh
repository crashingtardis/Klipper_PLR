#!/bin/bash

# Check if script is being run with sudo, if not, re-invoke with sudo
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run with sudo. Re-invoking with sudo..."
    sudo "$0" "$@"
    exit $?
fi

# Get the user executing the script
REAL_USER="$USER"

# Initialize the OWNER variable
OWNER=""

# Get the user's home directory
if [ -n "$SUDO_USER" ]; then
    echo "shell script executed with sudo: user is $SUDO_USER"
    if [ "$SUDO_USER" = "runner" ]; then
        USER_HOME="/home/runner"
        OWNER="runner"
    else
        USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
        OWNER="$SUDO_USER"
    fi
else
    USER_HOME=$(getent passwd "$USER" | cut -d: -f6)
    OWNER="$USER"
    echo "shell script executed without sudo: user is $USER"
fi

echo "Real user: $REAL_USER"
echo "User's home directory: $USER_HOME"
echo "Owner for chown: $OWNER"

# Define the Klipper directory using USER_HOME instead of HOME
KLIPPER_DIR="$USER_HOME/klipper"
echo "Klipper directory: $KLIPPER_DIR"

# Define the project directory
PROJECT_DIR="$PWD"
echo "Project directory: $PROJECT_DIR"

# Auto-detect firmware based on existing installations
if [ -f "$KLIPPER_DIR/klippy/plugins/gcode_shell_command.py" ]; then
    FIRMWARE="kalico"
    INSTALL_DIR="$KLIPPER_DIR/klippy/plugins"
    echo "Detected: Kalico - Installing to $INSTALL_DIR"
elif [ -f "$KLIPPER_DIR/klippy/extras/gcode_shell_command.py" ]; then
    FIRMWARE="klipper"
    INSTALL_DIR="$KLIPPER_DIR/klippy/extras"
    echo "Detected: Klipper - Installing to $INSTALL_DIR"
else
    # Default to Klipper if neither is detected
    FIRMWARE="klipper"
    INSTALL_DIR="$KLIPPER_DIR/klippy/extras"
    echo "No existing installation detected. Defaulting to Klipper - Installing to $INSTALL_DIR"
fi

echo ""

if [ -d "$PROJECT_DIR/.git" ]; then
  git -C "$PROJECT_DIR" remote set-url origin https://github.com/crashingtardis/Klipper_PLR.git \
    && echo "git remote aligned to Klipper_PLR.git" || echo "Warning: could not set git remote"
fi

# Create the variables.cfg file in the printer_data directory, if it doesn't exist
if [ ! -f "$USER_HOME/printer_data/config/variables.cfg" ]; then
  touch "$USER_HOME/printer_data/config/variables.cfg" && echo "variables.cfg created successfully." || echo "Error creating variables.cfg."
fi

# Copy the project files to the Klipper directory
cp -f "$PROJECT_DIR/plr.cfg" "$USER_HOME/printer_data/config/" && sed -i "s|\$USER_HOME|$USER_HOME|g" "$USER_HOME/printer_data/config/plr.cfg" && echo "plr.cfg copied and substituted successfully." || echo "Error copying plr.cfg."
rm -f "$INSTALL_DIR/gcode_shell_command.py"
ln -sf "$PROJECT_DIR/gcode_shell_command.py" "$INSTALL_DIR/gcode_shell_command.py" && echo "gcode_shell_command.py -> symlinked" || echo "Error symlinking gcode_shell_command.py"

# Make plr.sh & clear_plr.sh executable
#chmod +x "$USER_HOME/printer_data/plr/plr.sh" && echo "plr.sh made executable." || echo "Error making plr.sh executable."
#chmod +x "$USER_HOME/printer_data/plr/clear_plr.sh" && echo "clear_plr.sh made executable." || echo "Error making clear_plr.sh executable."

# Check if printer.cfg exists, create it if it doesn't
if [ ! -f "$USER_HOME/printer_data/config/printer.cfg" ]; then
    touch "$USER_HOME/printer_data/config/printer.cfg" && echo "printer.cfg created successfully." || echo "Error creating printer.cfg."
fi

# Check if the file exists
if [ ! -f "$USER_HOME/printer_data/config/printer.cfg" ]; then
  echo "Error: $USER_HOME/printer_data/config/printer.cfg does not exist."
fi

# Check if the string is already present in the file
if grep -Fxq '[include plr.cfg]' "$USER_HOME/printer_data/config/printer.cfg"; then
    echo "The string [include plr.cfg] is already present in the file."
else
    # Create a temporary file
    temp_file=$(mktemp)

    # Add the line [include plr.cfg] at the beginning of the file
    echo "[include plr.cfg]" > "$temp_file"
    cat "$USER_HOME/printer_data/config/printer.cfg" >> "$temp_file"

    # Replace the original file with the temporary file
    mv "$temp_file" "$USER_HOME/printer_data/config/printer.cfg"

    # Check if the string was added successfully
    if grep -q '[include plr.cfg]' "$USER_HOME/printer_data/config/printer.cfg"; then
        echo "The string [include plr.cfg] was successfully added."
    else
        echo "Error: the string [include plr.cfg] was not added."
    fi
fi

# Check if the variables.cfg file exists
if [ ! -f "$USER_HOME/printer_data/config/variables.cfg" ]; then
  echo "The file $USER_HOME/printer_data/config/variables.cfg does not exist. Creating..."
  # Attempt to create the variables.cfg file
  touch "$USER_HOME/printer_data/config/variables.cfg"

  # Check if the file was created successfully
  if [ -f "$USER_HOME/printer_data/config/variables.cfg" ]; then
    echo "The file $USER_HOME/printer_data/config/variables.cfg was created successfully."
  else
    echo "Error: Creating the file $USER_HOME/printer_data/config/variables.cfg failed."
  fi
else
  echo "The file $USER_HOME/printer_data/config/variables.cfg already exists."
fi

# Check if the moonraker.conf file exists
if [ ! -f "$USER_HOME/printer_data/config/moonraker.conf" ]; then
    echo "The file moonraker.conf does not exist, creating the file..."
    touch "$USER_HOME/printer_data/config/moonraker.conf"
fi

# Check if the string [include update_plr.cfg] is already present in the file
if grep -Fxq "[include update_plr.cfg]" "$USER_HOME/printer_data/config/moonraker.conf"; then
    echo "The string [include update_plr.cfg] is already present in the file moonraker.conf."
else
    echo "Adding the string [include update_plr.cfg] to the file moonraker.conf..."
    # Create a temporary file
    temp_file=$(mktemp)

    # Add the line [include update_plr.cfg] at the beginning of the file
    echo "[include update_plr.cfg]" > "$temp_file"
    cat "$USER_HOME/printer_data/config/moonraker.conf" >> "$temp_file"

    # Replace the original file with the temporary file
    mv "$temp_file" "$USER_HOME/printer_data/config/moonraker.conf"
fi

# Check if the update_plr.cfg file exists
if [ -f "$USER_HOME/printer_data/config/update_plr.cfg" ]; then
    echo "The file update_plr.cfg already exists, deleting the file..."
    rm "$USER_HOME/printer_data/config/update_plr.cfg"
fi

# Create a new update_plr.cfg file with cat EOF
echo "Creating a new update_plr.cfg file with cat EOF..."
cat > "$USER_HOME/printer_data/config/update_plr.cfg" << EOF
# plr-klipper update_manager entry
[update_manager Klipper_PLR]
type: git_repo
path: ~/Klipper_PLR
origin: https://github.com/crashingtardis/Klipper_PLR.git
primary_branch: main
system_dependencies: system_dependencies.json
is_system_service: False
managed_services: klipper
install_script: install.sh

EOF

# Make install.sh executable for Moonraker's automatic updates
chmod +x "$PROJECT_DIR/install.sh" && echo "install.sh made executable." || echo "Warning: Could not make install.sh executable."

# Check if the script is executed with sudo
echo "Checking script execution with sudo..."
if [ -n "$SUDO_USER" ]; then
    echo "The script is executed with sudo."
    # The SUDO_USER variable is set, so the script is executed with sudo
    REAL_USER="$SUDO_USER"
    echo "Real user (SUDO_USER) : $REAL_USER"
    
    echo "Real user's home directory (USER_HOME) : $USER_HOME"
    
    echo "Running chown command for $USER_HOME/printer_data/config/ with $OWNER:$OWNER"
    
    chown -R "$OWNER":"$OWNER" "$USER_HOME/printer_data/config/"
    echo "Chown command executed."
else
    echo "This script is not executed with sudo."
fi

# Print a message to the user
echo "Installation complete"
#end of script