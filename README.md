# Klipper PLR (Power Loss Recovery)

Klipper PLR (Forked from YUMI_PLR) is a simple print recovery system for Klipper & Kalico, a 3D printer firmware. It allows you to resume prints after a power loss or other types of MCU disconnection interruption. Please note there is no guarantee that it will work in 100% of cases because the Z-axis must not have moved, so do not touch the machine in case of a power cut.

## Prerequisites:
Having already installed Klipper or Kalico, Moonraker, and Mainsail (you can use Kiauh).
To install Klipper_PLR, follow the steps below:

## Installation:
Clone the Klipper_PLR repository from GitHub to your local machine:

```bash
git clone https://github.com/crashingtardis/Klipper_PLR.git
cd Klipper_PLR
./install.sh
```

The installation script will:
- Automatically invoke `sudo` if not already running with elevated privileges
- Auto-detect your firmware (Klipper or Kalico) based on existing installations
- Substitute `$USER_HOME` paths in configuration files for Klipper compatibility
- Configure Moonraker for automatic updates
- Create necessary configuration files

**Note:** You do not need to manually specify `sudo` - the script handles it automatically.

### Automatic Updates from Mainsail:
After initial installation, Klipper_PLR will be available in Mainsail's update manager. When you update from Mainsail, the `install.sh` script will automatically run to update your configuration without any manual intervention.

### Firmware Support:
- If you are using **Klipper**, the plugin is installed in `/klipper/klippy/extras/`
- If you are using **Kalico**, the plugin is installed in `/klipper/klippy/plugins/` (to prevent repo from showing as dirty in Mainsail)

The installation script automatically detects which firmware you're using and installs to the correct location.

### Slicer Configuration:
Add the following G-code to your slicer settings:

**Start G-code:**
```gcode
G31
save_last_file
SAVE_VARIABLE VARIABLE=was_interrupted VALUE=True
```

###end-gcode add in your slicer:
```bash
SAVE_VARIABLE VARIABLE=was_interrupted VALUE=False
clear_last_file
G31
```
###Before layer change G-gcode add in your slicer:
```bash
LOG_Z
```
To resume printing after a power cut, simply execute the 'RESUME_INTERRUPTED' macro in the MAINSAIL console or via the Macro button on the MAINSAIL dashboard.

## Uninstallation:
```bash
cd Klipper_PLR
./uninstall.sh
```

## Known Bugs:
(none currently)

## Notes:
- The preview image (thumbnail) of the resume file is rebuilt: plr.sh copies the
  original gcode header (slicer signature + thumbnail blocks) so Moonraker /
  Mainsail / KlipperScreen show the preview on the resume file.
- LOG_Z must be present (uncommented) in the slicer "Before layer change G-code"
  so power_resume_z is updated each layer; otherwise the resume Z height is not
  captured and RESUME_INTERRUPTED needs Z_HEIGHT passed manually.
 




