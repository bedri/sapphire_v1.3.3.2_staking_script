import { ref } from 'vue';

/**
 * Nuxt 3 Composable
 * File path: `/composables/useNodeMonitor.js`
 * This composable provides a clean interface to call our server API route.
 */
export function useNodeMonitor() {
    const data = ref(null);
    const pending = ref(false);
    const error = ref(null);

    /**
     * Calls the server API route to trigger the node info fetch and post.
     * @param {object} options - The options for the request.
     * @param {string} options.ticker - The ticker symbol (e.g., 'SAPP').
     * @param {string} options.postUrl - The URL to post the data to.
     * @param {number} [options.rpcPort] - Optional RPC port, defaults to server's value.
     */
    async function execute({ ticker, postUrl, rpcPort }) {
        pending.value = true;
        error.value = null;
        data.value = null;
        try {
            // Use Nuxt 3's $fetch to call our internal API route.
            // The body will be automatically stringified.
            const response = await $fetch('/api/node-monitor', {
                method: 'POST',
                body: { ticker, postUrl, rpcPort }
            });
            data.value = response;
        } catch (e) {
            error.value = e;
        } finally {
            pending.value = false;
        }
    }

    return { data, pending, error, execute };
}

/*
// --- Example Usage in a Nuxt 3 Page/Component (`/pages/index.vue`) ---

<script setup>
const { data, pending, error, execute } = useNodeMonitor();

async function handleButtonClick() {
  await execute({
    ticker: 'SAPP',
    postUrl: 'https://your-target-server.com/node' // Replace with your actual URL
    // rpcPort: 12345 // Optionally override the port
  });
}
</script>

<template>
  <div>
    <button @click="handleButtonClick" :disabled="pending">
      <span v-if="pending">Loading...</span>
      <span v-else>Get and Post Node Info</span>
    </button>

    <div v-if="error" style="color: red; margin-top: 1rem;">
      <h3>Error</h3>
      <pre>{{ error.data?.statusMessage || error.message }}</pre>
    </div>

    <div v-if="data" style="margin-top: 1rem;">
      <h3>Success! Response from {{ data.postUrl }}</h3>
      <pre>{{ data }}</pre>
    </div>
  </div>
</template>

*/
