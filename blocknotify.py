#!/usr/bin/env python3

# pip install python-dotenv
# install this to get rpc user and password from the .env file

import sys
import json
import requests
import argparse
import os
from dotenv import load_dotenv

def rpc_request(auth, port, method, params=[]):
    """Executes a JSON-RPC request and returns the result."""
    url = f"http://127.0.0.1:{port}"
    headers = {'content-type': 'application/json'}
    payload = {
        "method": method,
        "params": params,
        "jsonrpc": "2.0",
        "id": 0,
    }
    try:
        response = requests.post(url, headers=headers, auth=auth, data=json.dumps(payload))
        response.raise_for_status()
        json_response = response.json()
        if json_response.get('error'):
            print(f"RPC Error: {json_response['error']}", file=sys.stderr)
            sys.exit(1)
        return json_response['result']
    except requests.exceptions.RequestException as e:
        print(f"Error sending RPC request to {url}: {e}", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError:
        print("Error: Failed to parse JSON from RPC response.", file=sys.stderr)
        sys.exit(1)


def main():
    """
    Main function to gather node info via RPC and post it.
    """
    load_dotenv() # Load variables from .env file

    parser = argparse.ArgumentParser(description="Get node info and post it to a URL.")
    parser.add_argument("ticker", help="The ticker symbol of the coin (e.g., SAPP).")
    parser.add_argument("--posturl", required=True, help="The URL to post the node data to.")
    parser.add_argument("--rpcport", type=int, default=51475, help="The JSON-RPC port of the local daemon (default: 51475).")
    args = parser.parse_args()

    # --- RPC Configuration from .env file ---
    rpc_user = os.getenv("RPC_USER")
    rpc_password = os.getenv("RPC_PASSWORD")

    if not rpc_user or not rpc_password:
        print("Error: RPC_USER and RPC_PASSWORD must be set in the .env file.", file=sys.stderr)
        sys.exit(1)

    rpc_auth = (rpc_user, rpc_password)
    # -----------------------------------------

    # Get response from RPC
    info = rpc_request(rpc_auth, args.rpcport, "getinfo")

    # Parse info
    version = info.get("version")
    protocol_version = info.get("protocolversion")
    block_height = info.get("blocks")
    connections = info.get("connections")
    difficulty = info.get("difficulty")

    # Get Blockhash for the block_height
    block_hash = rpc_request(rpc_auth, args.rpcport, "getblockhash", [block_height])

    # Prepare the data for the POST request
    payload = {
        "ticker": args.ticker,
        "version": version,
        "protocolVersion": protocol_version,
        "numBlocks": block_height,
        "blockHash": block_hash,
        "connections": connections,
        "difficulty": difficulty,
    }

    # Execute the POST request
    post_headers = {
        "accept": "*/*",
        "Content-Type": "application/json"
    }

    try:
        response = requests.post(args.posturl, headers=post_headers, json=payload, verify=False)
        # The script doesn't check the response, but you could add it like this:
        # response.raise_for_status()
        # print("Request successful:", response.text)
    except requests.exceptions.RequestException as e:
        print(f"Error sending POST request to {args.posturl}: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    # Suppress InsecureRequestWarning from requests
    import urllib3
    urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
    main()
