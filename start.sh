#!/bin/bash
set -e

echo "📦 Installing dependencies..."

# Cloudflared download
if [ ! -f "./cloudflared" ]; then
  echo "⬇️ Downloading cloudflared..."
  curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o cloudflared
  chmod +x cloudflared
fi

# TTYD download
if [ ! -f "./ttyd" ]; then
  echo "⬇️ Downloading ttyd..."
  curl -L https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64 -o ttyd
  chmod +x ttyd
fi

# Check if port 7681 is free
PORT=7681
if lsof -i :7681 &>/dev/null; then
  PORT=7682
  echo "⚠️ Port 7681 in use. Using port $PORT"
fi

# Start ttyd
echo "🚀 Starting ttyd on port $PORT..."
./ttyd -p "$PORT" bash &

# Wait for ttyd to bind to the port
sleep 2
if ! lsof -i :"$PORT" &>/dev/null; then
  echo "❌ TTYD failed to start on port $PORT"
  exit 1
fi

# Start cloudflared tunnel
echo "🌐 Starting Cloudflare tunnel..."
./cloudflared tunnel --url http://localhost:$PORT --no-autoupdate &
sleep 3

echo "✅ Setup complete. Wait ~10s for your Cloudflare URL to appear in logs."
sleep infinity
