#!/bin/bash

# Get the user running the script
REAL_USER="$USER"

# Initialize the OWNER variable
OWNER=""

# Get the user's directory
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

# Automatically detect firmware version
echo ""
echo "Detecting firmware version..."
KLIPPER_INSTALL_DIR="$KLIPPER_DIR/klippy/extras"
KALICO_INSTALL_DIR="$KLIPPER_DIR/klippy/plugins"

KLIPPER_DETECTED=false
KALICO_DETECTED=false

if [ -L "$KLIPPER_INSTALL_DIR/gcode_shell_command.py" ] || [ -f "$KLIPPER_INSTALL_DIR/gcode_shell_command.py" ]; then
    KLIPPER_DETECTED=true
fi

if [ -L "$KALICO_INSTALL_DIR/gcode_shell_command.py" ] || [ -f "$KALICO_INSTALL_DIR/gcode_shell_command.py" ]; then
    KALICO_DETECTED=true
fi

# Determine which firmware to uninstall from
if [ "$KLIPPER_DETECTED" = true ] && [ "$KALICO_DETECTED" = false ]; then
    FIRMWARE="klipper"
    INSTALL_DIR="$KLIPPER_INSTALL_DIR"
    echo "Detected: Klipper - Uninstalling from $INSTALL_DIR"
elif [ "$KALICO_DETECTED" = true ] && [ "$KLIPPER_DETECTED" = false ]; then
    FIRMWARE="kalico"
    INSTALL_DIR="$KALICO_INSTALL_DIR"
    echo "Detected: Kalico - Uninstalling from $INSTALL_DIR"
elif [ "$KLIPPER_DETECTED" = true ] && [ "$KALICO_DETECTED" = true ]; then
    echo "Warning: Found gcode_shell_command.py in both Klipper and Kalico directories."
    echo "Uninstalling from both locations."
    FIRMWARE="both"
elif [ "$KLIPPER_DETECTED" = false ] && [ "$KALICO_DETECTED" = false ]; then
    echo "Warning: gcode_shell_command.py not found in either Klipper or Kalico directories."
    echo "Defaulting to Klipper. Checking $KLIPPER_INSTALL_DIR"
    FIRMWARE="klipper"
    INSTALL_DIR="$KLIPPER_INSTALL_DIR"
fi

echo ""

# Define the cleanup function
function cleanup {
  if [ "$FIRMWARE" = "klipper" ] || [ "$FIRMWARE" = "both" ]; then
    rm -f "$KLIPPER_INSTALL_DIR/gcode_shell_command.py" && echo "gcode_shell_command.py removed from Klipper." || echo "Error removing gcode_shell_command.py from Klipper"
  fi
  
  if [ "$FIRMWARE" = "kalico" ] || [ "$FIRMWARE" = "both" ]; then
    rm -f "$KALICO_INSTALL_DIR/gcode_shell_command.py" && echo "gcode_shell_command.py removed from Kalico." || echo "Error removing gcode_shell_command.py from Kalico"
  fi
  
  rm -f "$USER_HOME/printer_data/config/plr.cfg" && echo "plr.cfg removed." || echo "Error removing plr.cfg"
  echo "Cleanup complete"
}

# Call the cleanup function
cleanup

#end of script
