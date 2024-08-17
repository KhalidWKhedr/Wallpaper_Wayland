#!/bin/bash

PIDFILE="/var/run/user/$UID/mpvpaper.pid"
WALLPAPER_FILE="$HOME/.config/hypr/Wallpaper/wallpaper.txt"  # Ensured it's the correct wallpaper.txt
LOGFILE="$HOME/.config/hypr/Wallpaper/change_wallpaper.log"
declare -a PIDs

# Log function
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOGFILE"
}

# Determine the video path, either from the argument or from the wallpaper file
if [ -z "$1" ]; then
    if [ -f "$WALLPAPER_FILE" ]; then
        VIDEO_PATH=$(cat "$WALLPAPER_FILE")
    else
        log_message "No video argument provided, and no wallpaper file (wallpaper.txt) found."
        exit 1
    fi
else
    VIDEO_PATH="$1"
    echo "$VIDEO_PATH" > "$WALLPAPER_FILE"  # Save the provided path to wallpaper.txt
fi

# Log the wallpaper being used
log_message "Using video wallpaper: $VIDEO_PATH"

# Function to set the video wallpaper
_set_wallpaper() {
    prime-run mpvpaper --mpv-options="hwdec=auto --no-audio --loop" "$1" "$VIDEO_PATH" &
    PIDs+=($!)
}

# Kill all existing mpvpaper processes
log_message "Attempting to kill all mpvpaper processes."
if pgrep mpvpaper > /dev/null; then
    while IFS= read -r p; do
        log_message "Attempting to kill process $p."
        if ! kill -9 "$p" 2>/dev/null; then
            log_message "Failed to kill process $p."
        else
            log_message "Successfully killed process $p."
        fi
    done < <(pgrep mpvpaper)
    log_message "All mpvpaper processes killed."
else
    log_message "No running mpvpaper processes found."
fi

# Remove outdated PID file
if [[ -f "$PIDFILE" ]]; then
    rm "$PIDFILE"
    log_message "Removed outdated PID file."
fi

sleep 1  # Added sleep before starting new wallpaper

# Get active outputs and set the video wallpaper
for output in $(hyprctl monitors | grep "Monitor" | awk '{print $2}'); do
    _set_wallpaper "$output"
done

# Save new PIDs to file
printf "%s\n" "${PIDs[@]}" > "$PIDFILE"

# Ensure no mpvpaper processes are still running after cleanup
if pgrep mpvpaper > /dev/null; then
    log_message "There are still running mpvpaper processes after cleanup."
    pgrep -a mpvpaper >> "$LOGFILE"
else
    log_message "No mpvpaper processes running after cleanup."
fi

