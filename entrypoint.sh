#!/usr/bin/env bash

# exit from script if error was raised.
set -e

# error function is used within a bash function in order to send the error
# message directly to the stderr output and exit with a failure status so
# Docker's restart policy can react to it.
error() {
    echo "$1" > /dev/stderr
    exit 1
}

# load variables from .env if present (allows running without docker-compose)
if [ -f /app/.env ]; then
    set -o allexport
    source /app/.env
    set +o allexport
fi

# setting timezone for the running process (inherited by litd below)
export TZ="Europe/Zurich"


cd /root/.lit

cat > lit.conf << EOF
httpslisten=0.0.0.0:8443
uipassword=${CHOSENPASSWORD}
lnd.rpclisten=0.0.0.0:10009
lnd.restlisten=0.0.0.0:8080
lnd.listen=0.0.0.0:9735
lnd.tlsextraip=0.0.0.0
lnd.tlsdisableautofill=1
lnd.tlsextradomain=${SETHOST}
lnd.tlsextradomain=lit
lnd.tlsautorefresh=true
lnd-mode=integrated
lnd.bitcoin.active=1
lnd.bitcoin.mainnet=1
lnd.bitcoin.node=neutrino
lnd.feeurl=https://nodes.lightning.computer/fees/v1/btc-fee-estimates.json
lnd.protocol.option-scid-alias=true
lnd.protocol.zero-conf=true
lnd.alias=${SETALIAS}
lnd.externalip=${SETHOST}
EOF

# add the LND REST subdomain to the TLS cert only when configured
if [ -n "${LND_HOST}" ]; then
    echo "lnd.tlsextradomain=${LND_HOST}" >> lit.conf
fi

cd /app
# run the software
./litd
