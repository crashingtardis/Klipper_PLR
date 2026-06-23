#!/bin/bash

HOME_DIR="${USER_HOME:-$HOME}"
rm -rf "$HOME_DIR/printer_data/gcodes/plr" && echo "PLR cache cleared successfully." || echo "Error clearing PLR cache."