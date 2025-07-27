#!/bin/bash

# Install dependencies
sudo apt update
sudo apt install curl unzip -y

# Download ttyd (latest working release link for Linux x86_64)
wget https://github.com/tsl0922/ttyd/releases/download/1.7.3/ttyd.x86_64 -O ttyd
chmod +x ttyd

# Install Cloudflared
curl -fsSL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o cloudflared
chmod +x cloudflared

# Start ttyd in background
./ttyd -p 7681 bash &

# Start cloudflared tunnel in foreground
./cloudflared tunnel --url http://localhost:7681

# Optional: keep VM alive if tunnel fails or ends
sleep infinity
