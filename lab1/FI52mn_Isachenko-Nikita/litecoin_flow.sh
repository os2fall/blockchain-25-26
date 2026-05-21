#!/bin/bash

# Litecoin RPC Credentials
RPC_USER="admin"
RPC_PASS="0000"
RPC_HOST="127.0.0.1"
RPC_PORT="19443"
RPC_URL="http://${RPC_HOST}:${RPC_PORT}/"

echo "==========================================="
echo "1. Getting Blockchain Info"
echo "==========================================="
curl --silent --user "${RPC_USER}:${RPC_PASS}" \
  --data-binary '{"jsonrpc":"1.0","id":"curl_script","method":"getblockchaininfo","params":[]}' \
  -H 'content-type:text/plain;' \
  "${RPC_URL}" | python3 -m json.tool
echo -e "\n"

echo "==========================================="
echo "2. Creating a Wallet (testwallet)"
echo "==========================================="
# We must create a wallet first in modern versions of Litecoin Core
curl --silent --user "${RPC_USER}:${RPC_PASS}" \
  --data-binary '{"jsonrpc":"1.0","id":"curl_script","method":"createwallet","params":["testwallet"]}' \
  -H 'content-type:text/plain;' \
  "${RPC_URL}" | python3 -m json.tool
echo -e "\n"

echo "==========================================="
echo "3. Generating a new receiving address"
echo "==========================================="
ADDRESS_RESPONSE=$(curl --silent --user "${RPC_USER}:${RPC_PASS}" \
  --data-binary '{"jsonrpc":"1.0","id":"curl_script","method":"getnewaddress","params":[]}' \
  -H 'content-type:text/plain;' \
  "${RPC_URL}")

echo "Raw Response: $ADDRESS_RESPONSE"

# Extract the address 
ADDRESS=$(echo "$ADDRESS_RESPONSE" | grep -o '"result":"[^"]*' | cut -d'"' -f4)
echo "Extracted Address: ${ADDRESS}"
echo -e "\n"

echo "==========================================="
echo "4. Mining 101 blocks to the new address"
echo "==========================================="
echo "(Mining blocks in regtest so coinbase rewards mature...)"
curl --silent --user "${RPC_USER}:${RPC_PASS}" \
  --data-binary "{\"jsonrpc\":\"1.0\",\"id\":\"curl_script\",\"method\":\"generatetoaddress\",\"params\":[101, \"${ADDRESS}\"]}" \
  -H 'content-type:text/plain;' \
  "${RPC_URL}" > /dev/null
echo "101 Blocks Mined!"
echo -e "\n"

echo "==========================================="
echo "5. Checking Wallet Balance"
echo "==========================================="
curl --silent --user "${RPC_USER}:${RPC_PASS}" \
  --data-binary '{"jsonrpc":"1.0","id":"curl_script","method":"getbalance","params":[]}' \
  -H 'content-type:text/plain;' \
  "${RPC_URL}" | python3 -m json.tool
echo -e "\n"