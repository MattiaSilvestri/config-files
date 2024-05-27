#!/bin/bash
# Script to dynamically create symlink for CPU temperature

# Find the correct path to temp1_input
source_path=$(find /sys/devices/platform/coretemp.0/hwmon/ -name "temp1_input" -print -quit)

# Check if the source path is found
if [ -n "$source_path" ]; then
    # Determine the symlink path
    symlink_path="/home/mattia/.temp/core1"

    # Create or update the symlink
    ln -sf "$source_path" "$symlink_path"
else
    echo "Error: Unable to find the source path for temp1_input."
fi
