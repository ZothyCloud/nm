#!/bin/bash
set -e

echo "📦 Installing dependencies..."

# Cloudflared
if [ ! -f "./cloudflared" ]; then
  echo "⬇️ Downloading cloudflared..."
  curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o cloudflared
  chmod +x cloudflared
fi

# TTYD
if [ ! -f "./ttyd" ]; then
  echo "⬇️ Downloading ttyd..."
  curl -L https://github.com/tsl0922/ttyd/releases/latest/download/ttyd-linux-x86_64 -o ttyd
  chmod +x ttyd
fi

# Validate ttyd exists
if [ ! -x "./ttyd" ]; then
  echo "❌ TTYD not downloaded correctly or not executable"
  ls -l
  exit 1
fi

# Choose available port
PORT=7681
if lsof -i :7681 &>/dev/null; then
  PORT=7682
  echo "⚠️ Port 7681 busy. Using port $PORT"
fi

# Start TTYD
echo "🌐 Starting TTYD on port $PORT..."
nohup ./ttyd -p "$PORT" bash > ttyd.log 2>&1 &

sleep 2
if ! lsof -i :"$PORT" &>/dev/null; then
  echo "❌ TTYD failed to start on port $PORT"
  cat ttyd.log
  exit 1
fi

# Start Cloudflare tunnel
echo "☁️ Starting Cloudflare tunnel..."
nohup ./cloudflared tunnel --url http://localhost:$PORT --no-autoupdate > cf.log 2>&1 &

echo "✅ All services started. Logs:"
tail -f cf.log
