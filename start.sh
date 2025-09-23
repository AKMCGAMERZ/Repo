#!/bin/bash
set -e

# Colors
BLUE="\e[34m"
GREEN="\e[32m"
RED="\e[31m"
RESET="\e[0m"

# Vars
USER=unixnodes
BOT_DIR=/home/$USER
SERVICE_NAME=unixnodes-bot
NETWORK_NAME=powerhost-net
ENV_FILE=$BOT_DIR/env.txt
BOT_FILE=$BOT_DIR/bot.py

clear

# Banner (ASCII Art)
if ! command -v figlet &>/dev/null; then
    echo -e "${BLUE}Installing figlet for banner...${RESET}"
    sudo apt-get update -y &>/dev/null
    sudo apt-get install -y figlet &>/dev/null
fi

echo -e "${BLUE}"
figlet "I N S A A N"
echo -e "${RESET}"
sleep 0.5
echo -e "${GREEN}Welcome to InsaanBOT Installer${RESET}"
echo "--------------------------------------"
echo ""

# Helper for steps
step () {
    echo -ne "${BLUE}$1...${RESET} "
    if eval "$2" &>/tmp/insaanbot_step.log; then
        echo -e "${GREEN}✓${RESET}"
    else
        echo -e "${RED}✗${RESET}"
        cat /tmp/insaanbot_step.log
        exit 1
    fi
}

echo "1) Fresh Install"
echo "2) Update Mode"
read -p "Choose option [1-2]: " mode

if [ "$mode" == "1" ]; then
    step "Creating Docker network" "docker network create $NETWORK_NAME || true"
    if id "$USER" &>/dev/null; then
        echo -e "${GREEN}User $USER already exists${RESET}"
    else
        step "Creating user $USER" "sudo useradd -r -s /bin/false $USER && sudo usermod -aG docker $USER"
    fi
    step "Creating bot directory" "sudo mkdir -p $BOT_DIR && sudo chown -R $USER:docker $BOT_DIR"
    step "Copying bot.py" "sudo cp bot.py $BOT_FILE && sudo chown -R $USER:docker $BOT_DIR"

    if [ ! -f "$ENV_FILE" ]; then
        echo "Creating default env.txt..."
        sudo bash -c "cat > $ENV_FILE" <<EOL
DISCORD_TOKEN=your_real_bot_token_here
ADMIN_IDS=1415700444264529992
ADMIN_ROLE_ID=1418145362488852602
DEFAULT_OS_IMAGE=ubuntu:22.04
DOCKER_NETWORK=$NETWORK_NAME
MAX_CONTAINERS=100
MAX_VPS_PER_USER=3
WATERMARK="Power ⚡ Host ☁️ VPS Service"
WELCOME_MESSAGE="Welcome To Power ⚡ Host ☁️! Managed by InsaanXD"
EOL
        sudo chown $USER:docker $ENV_FILE
    fi
fi

echo ""
echo "🔑 Bot Token Setup"
echo "1) Load existing token"
echo "2) Enter new token"
read -p "Choose option [1-2]: " choice

if [ "$choice" == "1" ]; then
    BOT_TOKEN=$(grep "^DISCORD_TOKEN=" "$ENV_FILE" | cut -d '=' -f2-)
    echo -e "Loaded token: ${GREEN}$BOT_TOKEN${RESET}"
elif [ "$choice" == "2" ]; then
    read -p "Enter new bot token: " NEW_TOKEN
    step "Saving token" "sudo sed -i 's|^DISCORD_TOKEN=.*|DISCORD_TOKEN=$NEW_TOKEN|' $ENV_FILE"
else
    echo -e "${RED}Invalid choice${RESET}"
    exit 1
fi

if [ "$mode" == "1" ]; then
    echo "Creating systemd service..."
    sudo bash -c "cat >/etc/systemd/system/$SERVICE_NAME.service" <<EOL
[Unit]
Description=UnixNodes Bot
After=network.target docker.service
Requires=docker.service

[Service]
User=$USER
Group=docker
WorkingDirectory=$BOT_DIR
EnvironmentFile=$ENV_FILE
ExecStartPre=/usr/bin/docker network create $NETWORK_NAME || true
ExecStart=/usr/bin/python3 $BOT_FILE
Restart=always

[Install]
WantedBy=multi-user.target
EOL
    step "Reloading systemd" "sudo systemctl daemon-reload"
    step "Enabling service" "sudo systemctl enable $SERVICE_NAME"
fi

step "Restarting service" "sudo systemctl restart $SERVICE_NAME"

echo ""
echo -e "${GREEN}All done! Bot is running 🚀${RESET}"
echo "---------InsaanBOT output input----------"
