#!/bin/bash

# This script prepares the environment and runs the Grabby bot.

# --- Cookie File Handling ---
# This logic supports two methods for providing cookies, ensuring portability.

# 1. Fallback Method: Create from environment variable
# If APP_COOKIES_CONTENT is set, create the cookie file from its content.
# This is useful for platforms that only support env var secrets (like Hugging Face).
if [ -n "$APP_COOKIES_CONTENT" ] && [ -n "$COOKIES_FILE_PATH" ]; then
  echo "INFO: Found APP_COOKIES_CONTENT, creating cookie file at $COOKIES_FILE_PATH."
  # Create directory if it doesn't exist
  mkdir -p "$(dirname "$COOKIES_FILE_PATH")"
  echo "$APP_COOKIES_CONTENT" > "$COOKIES_FILE_PATH"
fi

# 2. Primary Method: Check for pre-existing file
# This checks if the cookie file exists at the path specified by COOKIES_FILE_PATH.
# This is the expected behavior for platforms that support file secrets (like Koyeb).
if [ -n "$COOKIES_FILE_PATH" ]; then
  if [ -f "$COOKIES_FILE_PATH" ]; then
    echo "INFO: Cookie file check PASSED. File exists at $COOKIES_FILE_PATH."
  else
    echo "WARN: Cookie file check FAILED. File does NOT exist at $COOKIES_FILE_PATH."
  fi
else
  echo "INFO: COOKIES_FILE_PATH not set. Proceeding without cookies."
fi

# --- Execute Application ---
echo "INFO: Starting Grabby application..."
exec grabby --config /config.toml
