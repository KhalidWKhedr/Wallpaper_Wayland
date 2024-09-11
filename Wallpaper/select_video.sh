#!/bin/bash

# Set the directory where your video wallpapers are stored
VIDEO_DIR="/home/khalidwaleedkhedr/Videos/Wallpapers"
LOGFILE="$HOME/.config/hypr/Wallpaper/change_wallpaper.log"
WALLPAPER_FILE="$HOME/.config/hypr/Wallpaper/current_wallpaper.txt"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOGFILE"
}

# Check if the directory exists
if [ ! -d "$VIDEO_DIR" ]; then
    log_message "Directory $VIDEO_DIR does not exist."
    echo "Directory $VIDEO_DIR does not exist."
    exit 1
fi

# List video files
VIDEO_LIST=$(find "$VIDEO_DIR" -type f \( -iname "*.mp4" -o -iname "*.mkv" \))

# Check if the list is empty
if [ -z "$VIDEO_LIST" ]; then
    log_message "No video files found in $VIDEO_DIR."
    echo "No video files found."
    exit 1
fi

# Extract video titles from the full paths
VIDEO_TITLES=$(echo "$VIDEO_LIST" | xargs -n 1 basename)

# Use fuzzel to select a video title
SELECTED_TITLE=$(echo "$VIDEO_TITLES" | fuzzel --dmenu --prompt "Select wallpaper:")

# Check if fuzzel command was successful
if [ $? -ne 0 ]; then
    log_message "fuzzel command failed or was canceled."
    echo "Failed to list videos or selection was canceled."
    exit 1
fi

# Find the full path corresponding to the selected title
SELECTED_VIDEO=$(echo "$VIDEO_LIST" | grep "/$SELECTED_TITLE$")

# If a video was selected, change the wallpaper
if [ -n "$SELECTED_VIDEO" ]; then
    # Save the selected video to the wallpaper file
    echo "$SELECTED_VIDEO" > "$WALLPAPER_FILE"
    
    # Check if the change_wallpaper.sh script exists and is executable
    if [ -x "$HOME/.config/hypr/Wallpaper/change_wallpaper.sh" ]; then
        log_message "Changing wallpaper to $SELECTED_VIDEO"
        "$HOME/.config/hypr/Wallpaper/change_wallpaper.sh" "$SELECTED_VIDEO"
    else
        log_message "change_wallpaper.sh script not found or not executable."
        echo "change_wallpaper.sh script not found or not executable."
        exit 1
    fi
else
    log_message "No video selected."
    echo "No video selected."
fi
