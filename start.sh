#!/bin/bash

# Colors
BLUE='\033[1;34m'
GREEN='\033[1;32m'
NC='\033[0m' # No Color

clear
echo -e "${BLUE}--------InsaanXD-------${NC}"
echo ""

# Ensure .env file exists
if [ ! -f .env ]; then
  touch .env
fi

# Check if token already exists in .env
DISCORD_TOKEN=$(grep '^DISCORD_TOKEN=' .env | cut -d '=' -f2-)

if [ -z "$DISCORD_TOKEN" ] || [ "$DISCORD_TOKEN" = "your_real_bot_token_here" ]; then
  read -p "Enter your Discord Bot Token: " DISCORD_TOKEN
  sed -i '/^DISCORD_TOKEN=/d' .env
  echo "DISCORD_TOKEN=$DISCORD_TOKEN" >> .env
fi

export $(grep -v '^#' .env | xargs)

echo -e "${GREEN}✅ Token saved in .env${NC}"

# Stylish setup steps
echo -e "${BLUE}Installing dependencies...${NC}"
apt install sudo -y > /dev/null 2>&1 && echo -e "${GREEN}✔ sudo installed${NC}"
apt install systemctl -y > /dev/null 2>&1 && echo -e "${GREEN}✔ systemctl installed${NC}"
pip install -r requirements.txt > /dev/null 2>&1 && echo -e "${GREEN}✔ Python requirements installed${NC}"

echo -e "${BLUE}Configuring user & service...${NC}"
sudo useradd -r -s /bin/false unixnodes > /dev/null 2>&1 && echo -e "${GREEN}✔ User unixnodes created${NC}"
sudo usermod -aG docker unixnodes > /dev/null 2>&1 && echo -e "${GREEN}✔ User added to docker group${NC}"
sudo systemctl enable unixnodes-bot.service > /dev/null 2>&1 && echo -e "${GREEN}✔ Service enabled${NC}"
sudo systemctl start unixnodes-bot.service > /dev/null 2>&1 && echo -e "${GREEN}✔ Service started${NC}"

echo ""
echo -e "${GREEN}🚀 Starting Power ⚡ Host ☁️ Bot...${NC}"

# Run the bot
python3 bot.py
