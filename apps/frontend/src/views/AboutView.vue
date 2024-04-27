<template>
  <div class="about">
    <h1>This is an about page2</h1>
    <br/>
    <button @click="onOauth">OAuth</button>
  </div>
</template>


<script setup lang="ts">
import { ApiClient } from '@/api'
const onOauth = async () => {
  const apiClient = new ApiClient()
  let result = await apiClient.getUrl()
  window.location.href = result.data.url
}
</script>

<style>
@media (min-width: 1024px) {
  .about {
    min-height: 100vh;
    display: flex;
    align-items: center;
  }
}
</style>
