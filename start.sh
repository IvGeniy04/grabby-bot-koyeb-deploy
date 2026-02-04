#!/bin/bash

# Define paths
RAW_COOKIE_FILE="/config/cookies.txt.raw"
FIXED_COOKIE_FILE="/config/cookies.txt"

# Check if Koyeb created the raw cookie file
if [ -f "$RAW_COOKIE_FILE" ]; then
    echo "INFO: Found raw cookie file at $RAW_COOKIE_FILE. Fixing newlines..."
    # Use sed to replace literal '\n' with actual newline characters
    # and write to a new, clean file.
    sed 's/\\n/\n/g' "$RAW_COOKIE_FILE" > "$FIXED_COOKIE_FILE"
    echo "INFO: Corrected cookie file created at $FIXED_COOKIE_FILE."
else
    echo "INFO: No raw cookie file found at $RAW_COOKIE_FILE. Proceeding without cookies."
fi

# Execute the main application command
echo "INFO: Starting Grabby application..."
exec grabby --config /config.toml
