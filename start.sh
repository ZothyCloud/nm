#!/bin/bash

set -e

echo "🔧 Setting up environment..."

# Link VM data (for persistent storage)
mkdir -p /vm_data
ln -s /home/runner/work/nm/nm /vm_data || true

# Install cloudflared
if [ ! -f "./cloudflared" ]; then
  echo "⬇️ Installing cloudflared..."
  curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o cloudflared
  chmod +x cloudflared
fi

# Install ttyd
if [ ! -f "./ttyd" ]; then
  echo "⬇️ Installing ttyd..."
  curl -LO https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64
  mv ttyd.x86_64 ttyd
  chmod +x ttyd
fi

# Start ttyd (web-based terminal)
echo "🚀 Starting ttyd on port 7681..."
./ttyd -p 7681 bash &
sleep 5

# Start Cloudflare tunnel
echo "🌐 Starting Cloudflare tunnel..."
./cloudflared tunnel --url http://localhost:7681 --no-autoupdate &

# Debug: Show running processes
ps aux | grep ttyd
ps aux | grep cloudflared

echo "✅ TTYD and Cloudflare started."
echo "🌍 Open the Cloudflare URL shown above (it appears in logs)."

# Keep container running
sleep infinity
