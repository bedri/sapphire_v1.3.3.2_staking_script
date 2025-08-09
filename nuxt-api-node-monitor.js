/**
 * Nuxt 3 Server API Route
 * File path: `/server/api/node-monitor.post.js`
 * This route receives ticker, postUrl, and rpcPort, fetches node info,
 * and then posts it to the specified URL.
 */

// Helper function to perform the JSON-RPC request
async function rpcRequest(auth, port, method, params = []) {
    const url = `http://127.0.0.1:${port}`;
    // btoa is available globally in Nuxt server routes
    const credentials = btoa(`${auth.username}:${auth.password}`);
    const headers = {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${credentials}`
    };
    const payload = {
        method: method,
        params: params,
        jsonrpc: '2.0',
        id: 0,
    };

    // $fetch is not available here, use native fetch
    const response = await fetch(url, {
        method: 'POST',
        headers: headers,
        body: JSON.stringify(payload)
    });

    if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
    }

    const jsonResponse = await response.json();
    if (jsonResponse.error) {
        throw new Error(`RPC Error: ${JSON.stringify(jsonResponse.error)}`);
    }
    return jsonResponse.result;
}

export default defineEventHandler(async (event) => {
    // Read the body of the incoming POST request
    const body = await readBody(event);
    const { ticker, postUrl, rpcPort = 51475 } = body;

    if (!ticker || !postUrl) {
        throw createError({
            statusCode: 400,
            statusMessage: 'Missing required parameters: ticker and postUrl'
        });
    }

    // --- RPC Configuration (Securely on the server) ---
    const rpcUser = 'BrpUJgD3yk';
    const rpcPassword = 'MeYPP1d2JLALBUn73K95qY';
    const rpcAuth = { username: rpcUser, password: rpcPassword };
    // --------------------------------------------------

    try {
        // 1. Get node info
        const info = await rpcRequest(rpcAuth, rpcPort, 'getinfo');

        // 2. Parse info
        const {
            version,
            protocolversion: protocolVersion,
            blocks: numBlocks,
            connections,
            difficulty,
        } = info;

        // 3. Get block hash
        const blockHash = await rpcRequest(rpcAuth, rpcPort, 'getblockhash', [numBlocks]);

        // 4. Prepare the final payload
        const finalPayload = {
            ticker,
            version,
            protocolVersion,
            numBlocks,
            blockHash,
            connections,
            difficulty,
        };

        // 5. Execute the final POST request to the external URL
        const finalResponse = await fetch(postUrl, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json', 'Accept': '*/*' },
            body: JSON.stringify(finalPayload)
        });

        if (!finalResponse.ok) {
            throw new Error(`Failed to post to external URL. Status: ${finalResponse.status}`);
        }

        // Return the response from the external URL
        return await finalResponse.json();

    } catch (error) {
        console.error('Error in node-monitor API route:', error);
        throw createError({
            statusCode: 500,
            statusMessage: error.message
        });
    }
});
