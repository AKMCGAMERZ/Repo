#!/bin/bash

# Load env file if it exists
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

# Ask for bot token if not set in .env
if [ -z "$DISCORD_TOKEN" ]; then
  read -p "Enter your Discord Bot Token: " DISCORD_TOKEN
  echo "DISCORD_TOKEN=$DISCORD_TOKEN" >> .env
fi

echo "Starting Power ⚡ Host ☁️ Bot..."

# Run the bot
python3 bot-1-fixed.py
