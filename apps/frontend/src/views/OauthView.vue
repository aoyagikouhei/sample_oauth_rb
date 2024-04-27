<script setup lang="ts">
import { onMounted } from 'vue'
import { useUrlSearchParams } from '@vueuse/core'
import { useRouter } from 'vue-router'
import { ApiClient } from '@/api'

const params = useUrlSearchParams('history')
const router = useRouter()

onMounted(async () => {
  const apiClient = new ApiClient()
  const code = Array.isArray(params.code) ? params.code[0] : params.code
  await apiClient.postOauth({ code })
  await router.push('/')
  window.location.reload()
})
</script>

<template>
  <main></main>
</template>
