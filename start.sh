#!/bin/bash

# Make sure script exits on error
set -e

# Install dependencies
sudo apt update
sudo apt install -y git curl wget build-essential cmake npm nodejs

# Install cloudflared
wget -O cloudflared.tgz https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.tgz
tar -xvzf cloudflared.tgz
sudo mv cloudflared /usr/local/bin/
chmod +x /usr/local/bin/cloudflared

# Install ttyd
git clone https://github.com/tsl0922/ttyd.git
cd ttyd
mkdir build && cd build
cmake ..
make
sudo make install
cd ../..
rm -rf ttyd

# Start ttyd in background
nohup ttyd -p 7681 bash > ttyd.log 2>&1 &

# Start Cloudflare tunnel
nohup cloudflared tunnel --url http://localhost:7681 > tunnel.log 2>&1 &

echo "✅ VM Ready with TTYD + Cloudflare"
echo "Sleeping to keep container alive..."

# Keep alive for 6 hours
sleep 6h
