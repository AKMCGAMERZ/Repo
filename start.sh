#!/bin/bash

# Ensure .env file exists
if [ ! -f .env ]; then
  touch .env
fi

# Check if token already exists in .env
DISCORD_TOKEN=$(grep '^DISCORD_TOKEN=' .env | cut -d '=' -f2-)

# Agar token missing hai to user se puche
if [ -z "$DISCORD_TOKEN" ] || [ "$DISCORD_TOKEN" = "your_real_bot_token_here" ]; then
  read -p "Enter your Discord Bot Token: " DISCORD_TOKEN

  # Purana token line hatao
  sed -i '/^DISCORD_TOKEN=/d' .env

  # Naya token save karo
  echo "DISCORD_TOKEN=$DISCORD_TOKEN" >> .env
fi

# Load all env variables
export $(grep -v '^#' .env | xargs)

echo "✅ Token saved in .env"
echo "🚀 Starting Power ⚡ Host ☁️ Bot..."

# Run the bot
python3 bot-1-fixed.py
