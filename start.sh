#!/bin/bash

mkdir -p vm_data

echo "Starting ttyd on port 7681..."
./ttyd -p 7681 bash &

echo "Starting Cloudflare Tunnel..."
./cloudflared tunnel --url http://localhost:7681 &
sleep 5

echo "VM is running. Make your changes inside the terminal."
echo "Auto-saving to vm-data branch every 10 minutes..."

while true; do
  git config --global user.name "ZothyBot"
  git config --global user.email "zothycloud@example.com"

  git add vm_data
  git commit -m "Auto backup at $(date)" || echo "No changes to commit."
  git push origin HEAD:vm-data

  sleep 600  # 10 minutes
done
