#!/bin/bash

echo "🔄 Restoring backup data if any..."
if [ -d "vm_data" ]; then
  echo "✅ vm_data directory already exists."
else
  echo "📁 Creating vm_data directory..."
  mkdir vm_data
fi

# Install ttyd
if [ ! -f "ttyd" ]; then
  echo "⬇️ Downloading ttyd..."
  wget https://github.com/tsl0922/ttyd/releases/download/1.7.3/ttyd.x86_64 -O ttyd
  chmod +x ttyd
fi

# Install cloudflared
if [ ! -f "cloudflared" ]; then
  echo "⬇️ Downloading cloudflared..."
  wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared
  chmod +x cloudflared
fi

echo "🚀 Starting ttyd on port 7681..."
./ttyd -p 7681 bash &

sleep 2

echo "🌐 Starting Cloudflare tunnel..."
./cloudflared tunnel --url http://localhost:7681 --no-autoupdate | tee cloudflare.log &

sleep 5

# Show the Cloudflare URL
CF_URL=$(grep -o 'https://.*\.trycloudflare.com' cloudflare.log | head -n 1)

if [ -n "$CF_URL" ]; then
  echo "✅ Your terminal is available at: $CF_URL"
else
  echo "❌ Cloudflare tunnel failed to initialize."
fi

# Keep the VM alive
echo "🕒 Sleeping to keep VM alive..."
sleep infinity
