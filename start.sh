#!/bin/bash

# Prepare persistent data directory
mkdir -p /vm_data
ln -s /vm_data ~/vm_data

# Install required packages
sudo apt update && sudo apt install -y curl wget npm

# Install ttyd
npm install -g ttyd

# Install Cloudflare tunnel
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb

# Start services
echo "🌐 Starting TTYD..."
nohup ttyd bash &

echo "☁️ Starting Cloudflare tunnel..."
nohup cloudflared tunnel --url http://localhost:7681 &

# Keep container alive
sleep infinity
