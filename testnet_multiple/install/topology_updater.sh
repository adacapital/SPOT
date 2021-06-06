#!/bin/bash
# This is only relevant for relay nodes.
NOW=`date +"%Y%m%d_%H%M%S"`
USERNAME=$(whoami)
NODE_PORT=3001 # must match your relay node port as set in the startup command
NODE_HOSTNAME="CHANGE ME"  # optional. must resolve to the IP you are requesting from
NODE_BIN="$HOME/.local/bin"
NODE_HOME=$HOME/node.relay
NODE_LOG_DIR=${NODE_HOME}/logs
GENESIS_JSON=$NODE_HOME/config/sgenesis.json
NETWORKID=$(cat $GENESIS_JSON | jq -r .networkId)
NODE_VALENCY=1   # optional for multi-IP hostnames
NWMAGIC=$(cat $GENESIS_JSON | jq -r .networkMagic)

# this script is meant to be run via crontab, meaning .bashrc won't be run so we must set a couple of environment variable properly
export PATH="$NODE_BIN:$PATH"
export CARDANO_NODE_SOCKET_PATH="$NODE_HOME/socket/node.socket"

if [[ $NETWORKID == "Mainnet" ]]; then NETWORK_IDENTIFIER="--mainnet"; else NETWORK_IDENTIFIER="--testnet-magic $NWMAGIC"; fi

BLOCK_NO=$(cardano-cli query tip $NETWORK_IDENTIFIER | jq -r .block )
 
# Note:
# if you run your node in IPv4/IPv6 dual stack network configuration and want announced the
# IPv4 address only please add the -4 parameter to the curl command below  (curl -4 -s ...)
if [[ $NODE_HOSTNAME != "CHANGE ME" ]]; then
    T_HOSTNAME="&hostname=$NODE_HOSTNAME"
else
    T_HOSTNAME=''
fi

echo "NODE_PORT: $NODE_PORT"
echo "NODE_HOSTNAME: $NODE_HOSTNAME"
echo "NODE_HOME: $NODE_HOME"
echo "NODE_LOG_DIR: $NODE_LOG_DIR"
echo "GENESIS_JSON: $GENESIS_JSON"
echo "NETWORKID: $NETWORKID"
echo "NWMAGIC: $NWMAGIC"
echo "NETWORK_IDENTIFIER: $NETWORK_IDENTIFIER"
echo "BLOCK_NO: $BLOCK_NO"
echo "T_HOSTNAME: $T_HOSTNAME"
echo "MAX_PEERS: $MAX_PEERS"

if [[ ! -d $NODE_LOG_DIR ]]; then
    mkdir -p $NODE_LOG_DIR
fi

URL="https://api.clio.one/htopology/v1/?max=$MAX_PEERS&port=$NODE_PORT&blockNo=$BLOCK_NO&valency=$NODE_VALENCY&magic=$NWMAGIC$T_HOSTNAME"
# echo "NOW: $NOW, NODE_PORT: $NODE_PORT, NODE_HOSTNAME: $NODE_HOSTNAME, NODE_HOME: $NODE_HOME, GENESIS_JSON: $GENESIS_JSON, NETWORKID: $NETWORKID, NWMAGIC: $NWMAGIC, NETWORK_IDENTIFIER: $NETWORK_IDENTIFIER, BLOCK_NO: $BLOCK_NO, T_HOSTNAME: $T_HOSTNAME" >> $NODE_LOG_DIR/topology_updater_lastresult.json
# echo "PATH: $PATH, CARDANO_NODE_SOCKET_PATH: $CARDANO_NODE_SOCKET_PATH" >> $NODE_LOG_DIR/topology_updater_lastresult.json
# echo "NOW: $NOW, URL: $URL" >> $NODE_LOG_DIR/topology_updater_lastresult.json

# curl -4 -s "https://api.clio.one/htopology/v1/?port=$NODE_PORT&blockNo=$BLOCK_NO&valency=$NODE_VALENCY&magic=$NWMAGIC$T_HOSTNAME" | tee -a $NODE_LOG_DIR/topology_updater_lastresult.json
curl -4 -s "$URL" | tee -a $NODE_LOG_DIR/topology_updater_lastresult.json