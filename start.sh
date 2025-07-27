#!/bin/bash

# Restore VM data if exists
if [ -d ".vm_data" ]; then
  echo "✅ Restoring VM data..."
  cp -r .vm_data/* /
fi

# Install SSHX
curl -fsSL https://get.cloudflared.com | bash
npm install -g ttyd

# Start ttyd with bash shell
echo "🌐 Starting TTYD..."
nohup ttyd -p 7681 bash &

# Start Cloudflare tunnel
echo "☁️ Starting Cloudflare tunnel..."
nohup cloudflared tunnel --url http://localhost:7681 &

# Keep process alive
sleep infinity
