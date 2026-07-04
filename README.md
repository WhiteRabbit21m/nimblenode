# Nimble Node

Setup a Lightning Neutrino Node with LIT and Letsencrypt in seconds on a tiny VPS

## Quick install (guided)

The fastest way is the guided installer, which checks prerequisites, prepares `.env`, starts the services, creates the wallet and optionally configures BOS, ThunderHub and the Telegram bot:

```
git clone https://github.com/massmux/nimblenode
cd nimblenode
sudo ./scripts/install
```

On the first run it creates `.env` from the template and asks you to fill it in (UI password, alias, and the `SETHOST` / `THUB_HOST` / `LND_HOST` domains plus `LETSENCRYPT_EMAIL`). Set the matching DNS A records, then run `sudo ./scripts/install` again to complete the setup.

The manual steps below are still available if you prefer to run each part yourself.

## Install and run

Register a domain name and point the DNS A record to the VPS's public IP. Don't start the procedure until the zone is propagated and you have a fully qualified domain name which A to your VPS

```
git clone https://github.com/massmux/nimblenode
```

- edit .env file setting: 1) the UI password (at least 8 chars long), 2) your node's ALIAS, 3) your fully qualified hostname
- pull the image from dockerhub

```
docker pull massmux/lit
```

- Run the containers

```
cd nimblenode
docker compose up -d
```

- Create the wallet. first usage

```
./scripts/create
```

You will be asked about the wallet encryption key and how to setup the seed phrase. Backup them all carefully offline.

- that's it
- after around 20 minutes, connect to the server with:

```
https://your-domain-name
```

IMPORTANT: if you stop the docker container and restart you need to unlock your wallet with command

```
./scripts/unlock
```

## BOS

Balance of Satoshis (BOS) is preinstalled. To get this tool automatically configured, just run the command below. NB: You must execute this script only after created the LND Wallet (with /scripts/create).

```
./scripts/initbos
```

then you can use the tool by entering the container:

```
docker exec -ti bos bash
```

### Telegram bot (optional)

BOS can send node notifications to a Telegram bot and run persistently. After BOS is initialized (`./scripts/initbos`), create a bot with @BotFather and run:

```
./scripts/initbostelegram
```

The script saves your bot token, starts the bot and asks you to send `/connect` to it on Telegram. Paste back the connection code it replies with, and the bot switches to connected mode. From then on it runs persistently and reconnects automatically after container or VPS restarts (no need to run `/connect` again).

Check its status with:

```
docker logs -f bos
```

## ThunderHub

ThunderHub is a web UI to manage your node. It is served through the built-in reverse proxy (nginx-proxy + acme-companion) on its own subdomain with an automatic Let's Encrypt certificate.

Before starting, in your `.env` set `THUB_HOST` (e.g. `thunderhub.your-domain-name`) and `LETSENCRYPT_EMAIL`, and add a DNS A record for that subdomain pointing to your VPS.

Then, after the LND wallet has been created (with `./scripts/create`), run:

```
./scripts/initthub
```

The script asks for a master password (or generates one), writes `thubConfig.yaml`, and starts ThunderHub and the reverse proxy. Once the certificate is issued you can access it at:

```
https://thunderhub.your-domain-name
```

## LND REST API

To connect external apps (e.g. Zeus, LNbits) via a clean URL instead of a raw IP and port, the node exposes LND's REST API on its own subdomain through the reverse proxy, with a valid Let's Encrypt certificate.

Set `LND_HOST` in your `.env` (e.g. `lnd.your-domain-name`) and add a DNS A record for that subdomain pointing to your VPS. After `docker compose up -d`, the endpoint is:

```
https://lnd.your-domain-name
```

Apps authenticate with a macaroon (no IP/port and no custom certificate needed, since the proxy serves a trusted certificate). The URL alone grants no access: every request requires a valid macaroon.

Security note: for third-party apps prefer a least-privilege macaroon over `admin.macaroon` (which can spend funds). Consider also restricting access by IP at the proxy level.

### Custom macaroons

To generate a least-privilege macaroon for an app (instead of the all-powerful `admin.macaroon`), run:

```
./scripts/mkmacaroon
```

It offers ready-made profiles (read-only, invoice-only) or a custom set of `entity:action` permissions, can restrict the macaroon to a single IP address, and prints it in both hex and base64 for use with the REST endpoint above.

## Maintenance

Just connect to your running container with

```
docker exec -ti lit bash
```

then you can access the lncli command as usual to manage your node from the command line.

## Reset the node

This will completely whipeout your node and all lightning data (so be sure to have a backup or to have emptied all your funds). This is nice to redo the stuff from the beginning or to create a fresh node.

```
./scripts/reset
```


The whole system is available and configured on [DENALI](https://denali.pro) Lightning Node (LN2) VPS.
