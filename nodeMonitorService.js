/**
 * Executes a JSON-RPC request to the local daemon using the fetch API.
 * @param {object} auth - The authentication object { username, password }.
 * @param {number} port - The RPC port.
 * @param {string} method - The RPC method name.
 * @param {Array} params - The parameters for the RPC method.
 * @returns {Promise<any>} The result from the RPC call.
 */
async function rpcRequest(auth, port, method, params = []) {
    const url = `http://127.0.0.1:${port}`;
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

    try {
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
    } catch (error) {
        console.error(`Error sending RPC request to ${url}:`, error);
        throw error;
    }
}

/**
 * Gathers node information via RPC and posts it to a specified URL.
 * This service is designed to be used in a Vue 3 application.
 *
 * @param {string} ticker - The ticker symbol of the coin (e.g., 'SAPP').
 * @param {string} postUrl - The URL to post the node data to.
 * @param {number} [rpcPort=51475] - The JSON-RPC port of the local daemon.
 * @returns {Promise<object>} The response from the final POST request.
 */
export async function postNodeInfo({ ticker, postUrl, rpcPort = 51475 }) {
    // --- RPC Configuration ---
    // WARNING: Hardcoding credentials in frontend code is a security risk.
    // Consider using a backend proxy or environment variables.
    const rpcUser = 'BrpUJgD3yk';
    const rpcPassword = 'MeYPP1d2JLALBUn73K95qY';
    const rpcAuth = { username: rpcUser, password: rpcPassword };
    // -------------------------

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

        // 4. Prepare the payload for the external server
        const finalPayload = {
            ticker,
            version,
            protocolVersion,
            numBlocks,
            blockHash,
            connections,
            difficulty,
        };

        // 5. Execute the final POST request
        const postHeaders = {
            'Accept': '*/*',
            'Content-Type': 'application/json',
        };
        
        console.log('Sending final payload:', finalPayload);
        
        const finalResponse = await fetch(postUrl, {
            method: 'POST',
            headers: postHeaders,
            body: JSON.stringify(finalPayload)
        });

        if (!finalResponse.ok) {
            throw new Error(`HTTP error! status: ${finalResponse.status}`);
        }

        console.log('Successfully posted node info.');
        return await finalResponse.json();

    } catch (error) {
        console.error('Failed to complete node info posting process:', error);
        throw error;
    }
}

/*
// --- Example Usage in a Vue 3 Component ---

<script setup>
import { ref } from 'vue';
import { postNodeInfo } from './nodeMonitorService.js';

const responseData = ref(null);
const isLoading = ref(false);
const error = ref(null);

async function handleButtonClick() {
  isLoading.value = true;
  error.value = null;
  try {
    const data = await postNodeInfo({
      ticker: 'SAPP',
      postUrl: 'https://your-target-server.com/node', // Replace with your actual URL
      rpcPort: 51475 // This is optional
    });
    responseData.value = data;
  } catch (e) {
    error.value = e.message;
  } finally {
    isLoading.value = false;
  }
}
</script>

<template>
  <div>
    <button @click="handleButtonClick" :disabled="isLoading">
      {{ isLoading ? 'Loading...' : 'Get and Post Node Info' }}
    </button>
    <div v-if="error">
      <h3>Error</h3>
      <pre>{{ error }}</pre>
    </div>
    <div v-if="responseData">
      <h3>Response</h3>
      <pre>{{ responseData }}</pre>
    </div>
  </div>
</template>

*/
