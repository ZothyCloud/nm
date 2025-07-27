#!/bin/bash

# Create a persistent folder if not exists
mkdir -p vm_data

# Move into it
cd vm_data

# Update & install tools
sudo apt update
sudo apt install -y unzip curl

# Download ttyd
wget https://github.com/tsl0922/ttyd/releases/download/1.7.4/ttyd.x86_64 -O ttyd
chmod +x ttyd

# Download cloudflared
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared
chmod +x cloudflared

# Start ttyd in background
./ttyd -p 7681 bash &

# Start cloudflared tunnel
./cloudflared tunnel --url http://localhost:7681 --no-autoupdate &

# Keep the runner alive
sleep infinity
