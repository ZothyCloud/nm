#!/bin/bash

# Create persistent volume directory if not exists
mkdir -p /vm_data
ln -s /vm_data ~/vm_data

# Install dependencies
sudo apt update && sudo apt install -y curl wget npm

# Install ttyd
npm install -g ttyd

# Install cloudflared
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb

# Start TTYD and Cloudflare Tunnel
echo "🌐 Starting TTYD..."
nohup ttyd bash &

echo "☁️ Starting Cloudflare tunnel..."
nohup cloudflared tunnel --url http://localhost:7681 &

# Sleep forever to keep GitHub Actions VM alive
sleep infinity
