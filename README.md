# Klipper PLR (Power Loss Recovery)

Klipper PLR (Forked from YUMI_PLR) is a simple print recovery system for Klipper & Kalico, a 3D printer firmware. It allows you to resume prints after a power loss or other types of MCU disconnection interruption. Please note there is no guarantee that it will work in 100% of cases because the Z-axis must not have moved, so do not touch the machine in case of a power cut.

## Prerequisites:
Having already installed Klipper or Kalico, Moonraker, and Mainsail (you can use Kiauh).
To install Klipper_PLR, follow the steps below:

## Installation:
1. Clone the Klipper_PLR Klipper repository from GitHub to your local machine:

Please note that if you are using Klipper, plr.cfg will be installed in /klipper/klippy/extras/
If you are using Kalico, plr.cfg will be installed in /klipper/klippy/plugins
For Kalico, this is to avoid the repo showing as dirty in Mainsail.

```bash
git clone https://github.com/crashingtardis/Klipper_PLR.git
cd Klipper_PLR
./install.sh
```

###start-gcode add in your slicer:
```bash
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
6. To resume printing after a power cut, simply execute the 'RESUME_INTERRUPTED' macro in the MAINSAIL console or via the Macro button on the MAINSAIL dashboard.

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
 




