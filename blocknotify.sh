#!/bin/bash

# First parameter $1 is ID
ID=$1

# Second parameter $2 is TICKER
TICKER=$2

# Third parameter $3 is the JSONRPC cli name
CLI=$3

# Get response for "$CLI getinfo"
INFO=$( $CLI getinfo )

# Parse Version Info
VERSION=$( echo $INFO | jq ".version" )

# Parse Protocol Version Info
PROTOCOL_VERSION=$( echo $INFO | jq ".protocolversion" )

# Parse Block Height Info
BLOCK_HEIGHT=$( echo $INFO | jq ".blocks" )

# Get Blockhash for $BLOCK_HEIGHT
BLOCK_HASH=$( $CLI getblockhash $BLOCK_HEIGHT )

# Parse Number of Connections
CONNECTIONS=$( echo $INFO | jq ".connections" )

# Parse Difficulty
DIFFICULTY=$( echo $INFO | jq ".difficulty" )

# Execute the POST request
RESPONSE=$( curl -s --insecure -X POST "https://5.9.65.185:9099/node" -H  "accept: /" -H  "Content-Type: application/json" -d '{"nodeId":"'$( echo $ID )'","ticker":"'$( echo $TICKER )'","version":"'$( echo $VERSION )'","protocolVersion":"'$( echo $PROTOCOL_VERSION )'","numBlocks":'$( echo $BLOCK_HEIGHT )',"blockHash":"'$( echo $BLOCK_HASH )'","connections":'$( echo $CONNECTIONS )',"difficulty":'$( echo $DIFFICULTY )'}' 2>/dev/null )
