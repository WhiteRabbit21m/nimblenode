#!/usr/bin/env bash

###############################################################################
# Startup wrapper for the BOS container.
#
# It decides how to launch Balance of Satoshis based on the Telegram setup
# found in the persistent .bos directory:
#   - token + connect code -> run the Telegram bot in connected mode
#                             (persistent, auto-reconnects on restart)
#   - token only           -> run the bot so you can /connect and get a code
#   - neither              -> idle, keeping the container available for
#                             interactive use (docker exec) and init scripts
###############################################################################

set -e

BOS_BIN="/app/bos"
BOS_DIR="/home/node/.bos"
KEY_FILE="$BOS_DIR/telegram_bot_api_key"
CODE_FILE="$BOS_DIR/telegram_connect_code"

if [ -f "$KEY_FILE" ] && [ -s "$CODE_FILE" ]; then
    echo "Starting BOS Telegram bot (connected mode)..."
    exec "$BOS_BIN" telegram --connect "$(cat "$CODE_FILE")"
elif [ -f "$KEY_FILE" ]; then
    echo "Starting BOS Telegram bot (awaiting /connect)..."
    echo "Open Telegram and send /connect to your bot to obtain the connection code."
    exec "$BOS_BIN" telegram
else
    echo "Telegram not configured. Run ./scripts/initbostelegram on the host."
    echo "Container idling; use 'docker exec -ti bos bash' for manual commands."
    exec sleep infinity
fi
