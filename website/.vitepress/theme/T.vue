<template>
  <div :class="['t-line', { 't-in': isInput, 't-out': !isInput, 't-ok': ok, 't-warn': warn, 't-err': err, 't-dim': dim, 't-hi': hi }]">
    <span v-if="isInput" class="t-prompt">&#x276f;</span>
    <span class="t-content"><slot /></span>
  </div>
</template>

<script setup lang="ts">
const props = defineProps<{
  in?: boolean
  ok?: boolean
  warn?: boolean
  err?: boolean
  dim?: boolean
  hi?: boolean
}>()

const isInput = props.in !== undefined && props.in !== false
</script>

<style scoped>
.t-line {
  white-space: pre-wrap;
  word-wrap: break-word;
  padding: 2px 0;
}

/* ── User input ── */
.t-in {
  margin-top: 16px;
  padding: 6px 10px;
  background: rgba(13, 148, 136, 0.08);
  border-radius: 4px;
  border-left: 3px solid #0D9488;
}

.t-in:first-child {
  margin-top: 0;
}

.t-prompt {
  color: #2DD4BF;
  font-weight: 700;
  margin-right: 8px;
  user-select: none;
}

.t-in .t-content {
  color: #F0FDFA;
  font-weight: 500;
}

/* ── Claude response ── */
.t-out {
  padding-left: 12px;
  color: #E2E8F0;
}

.t-out + .t-out {
  margin-top: 0;
}

.t-in + .t-out {
  margin-top: 8px;
}

/* Semantic modifiers */
.t-ok .t-content { color: #34D399; font-weight: 500; }
.t-warn .t-content { color: #FBBF24; }
.t-err .t-content { color: #F87171; }
.t-dim .t-content { color: #475569; }
.t-hi .t-content { color: #5EEAD4; }
</style>
