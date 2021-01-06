#!/bin/bash

# Install jq (a powerful json tool library for bash)
sudo apt install jq curl -y > /dev/null 2>&1

# First parameter $1 is ID
ID=$1

# Second parameter $2 is TICKER
TICKER=$2

# Third parameter $3 is the JSONRPC cli name
CLI=$3

# Get response for "$CLI getinfo"
INFO=$( $CLI getinfo )
#echo -e $INFO | jq

# Parse Version Info
VERSION=$( echo $INFO | jq ".version" )
#echo -e "Version=$VERSION\n"

# Parse Protocol Version Info
PROTOCOL_VERSION=$( echo $INFO | jq ".protocolversion" )
#echo -e "Protocol Version=$PROTOCOL_VERSION\n"

# Parse Block Height Info
BLOCK_HEIGHT=$( echo $INFO | jq ".blocks" )
#echo -e "Block Height=$BLOCK_HEIGHT\n"

# Get Blockhash for $BLOCK_HEIGHT
BLOCK_HASH=$( $CLI getblockhash $BLOCK_HEIGHT )
#echo -e "Block Hash=$BLOCK_HASH\n"

# Parse Number of Connections
CONNECTIONS=$( echo $INFO | jq ".connections" )
#echo -e "Connections=$CONNECTIONS\n"

# Parse Difficulty
DIFFICULTY=$( echo $INFO | jq ".difficulty" )
#echo -e "Difficulty=$DIFFICULTY\n"

# Execute the POST request
RESPONSE=$( curl -s --insecure -X POST "https://5.9.65.185:9099/node" -H  "accept: /" -H  "Content-Type: application/json" -d '{"nodeId":"'$( echo $ID )'","ticker":"'$( echo $TICKER )'","version":"'$( echo $VERSION )'","protocolVersion":"'$( echo $PROTOCOL_VERSION )'","numBlocks":'$( echo $BLOCK_HEIGHT )',"blockHash":"'$( echo $BLOCK_HASH )'","connections":'$( echo $CONNECTIONS )',"difficulty":'$( echo $DIFFICULTY )'}' 2>/dev/null )

echo -e "Response from POST:" 
echo -e $RESPONSE | jq

# Execute a GET request to see the records
RECORDS=$( curl -s --insecure -X GET "https://5.9.65.185:9099/node" -H  "accept: text/plain" 2>/dev/null )

echo -e "\nRecords (via GET):"
echo -e $RECORDS | jq
echo -e "\n\n"

