#!/bin/bash
set -e

INSTALL_DIR="$HOME/cf-ttyd"
PORT=7681

mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

echo "📁 Working in: $INSTALL_DIR"

# 🟡 Install ttyd
if [ ! -f "ttyd" ]; then
  echo "⬇️ Downloading ttyd..."
  curl -L https://github.com/tsl0922/ttyd/releases/latest/download/ttyd-linux-x86_64 -o ttyd
  chmod +x ttyd
fi

# 🟡 Install cloudflared
if ! command -v cloudflared &>/dev/null; then
  echo "⬇️ Installing cloudflared..."
  curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb -o cloudflared-linux-amd64.deb
  sudo dpkg -i cloudflared-linux-amd64.deb
fi

# ✅ Confirm installations
echo "✅ ttyd version:"
./ttyd --version || echo "ttyd not executable!"

echo "✅ cloudflared version:"
cloudflared --version || echo "cloudflared not found!"

# 🚀 Start ttyd (shell on port)
echo "🌐 Starting ttyd on port $PORT..."
nohup ./ttyd -p $PORT bash > ttyd.log 2>&1 &

sleep 2
if ! lsof -i :$PORT &>/dev/null; then
  echo "❌ TTYD failed to start on port $PORT"
  cat ttyd.log
  exit 1
fi

# 🚀 Start Cloudflare tunnel
echo "☁️ Starting Cloudflare tunnel..."
nohup cloudflared tunnel --url http://localhost:$PORT --no-autoupdate > cf.log 2>&1 &

# 🔁 Wait for URL and display it
echo "⏳ Waiting for Cloudflare URL..."
sleep 5

CF_URL=$(grep -o 'https://[a-zA-Z0-9.-]*\.trycloudflare\.com' cf.log | head -n1)

if [ -z "$CF_URL" ]; then
  echo "❌ Could not extract Cloudflare URL."
  cat cf.log
  exit 1
fi

echo "✅ Access your terminal at:"
echo "$CF_URL"
