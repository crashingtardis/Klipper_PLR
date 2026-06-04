# PLR Klipper

YUMI_PLR for Klipper is a simple print recovery system for Klipper, a 3D printer firmware. It allows you to resume prints after a power loss or other types of MCU disconnection interruption. Please note there is no guarantee that it will work in 100% of cases because the Z-axis must not have moved, so do not touch the machine in case of a power cut.

## Prerequisites
Being on a user named 'pi' is mandatory. With the user pi, having already installed Klipper, Moonraker, and Mainsail (you can use Kiauh).

To install YUMI_PLR Klipper, follow the steps below:
You must have created your Klipper installation with the user 'pi'; the script does not yet fully handle other cases.

## Installation
1. Clone the YUMI_PLR Klipper repository from GitHub to your local machine:
```bash
git clone https://github.com/Yumi-Lab/YUMI_PLR.git
cd YUMI_PLR
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

## Known Bugs:
(none currently)

## Notes:
- The preview image (thumbnail) of the resume file is rebuilt: plr.sh copies the
  original gcode header (slicer signature + thumbnail blocks) so Moonraker /
  Mainsail / KlipperScreen show the preview on the resume file.
- LOG_Z must be present (uncommented) in the slicer "Before layer change G-code"
  so power_resume_z is updated each layer; otherwise the resume Z height is not
  captured and RESUME_INTERRUPTED needs Z_HEIGHT passed manually.
 




