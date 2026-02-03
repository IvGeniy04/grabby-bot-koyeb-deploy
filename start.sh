#!/bin/bash

# Create a config directory if it doesn't exist
mkdir -p /config

# Check if APP_COOKIES_CONTENT environment variable is set
if [ -n "$APP_COOKIES_CONTENT" ]; then
  echo "APP_COOKIES_CONTENT found, writing to /config/cookies.txt"
  echo "$APP_COOKIES_CONTENT" > /config/cookies.txt
  # Set COOKIES_FILE_PATH for the Rust application
  export COOKIES_FILE_PATH="/config/cookies.txt"
else
  echo "APP_COOKIES_CONTENT not found, not creating cookies.txt"
fi

# Execute the main application command
exec grabby --config /config.toml
