#!/bin/bash

# Create a config directory if it doesn't exist
mkdir -p "$(dirname "$COOKIES_FILE_PATH")"

# Check if APP_COOKIES_CONTENT is provided and a path is set
if [ -n "$APP_COOKIES_CONTENT" ] && [ -n "$COOKIES_FILE_PATH" ]; then
  echo "APP_COOKIES_CONTENT found, writing to $COOKIES_FILE_PATH"
  echo "$APP_COOKIES_CONTENT" > "$COOKIES_FILE_PATH"
elif [ -n "$COOKIES_FILE_PATH" ]; then
  echo "Using existing cookie file at $COOKIES_FILE_PATH (created by Koyeb file secret)"
else
  echo "No cookie file configuration found, proceeding without cookies."
fi

# Execute the main application command
exec grabby --config /config.toml
