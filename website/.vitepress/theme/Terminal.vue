<template>
  <div class="terminal">
    <div class="terminal-chrome">
      <span class="terminal-dots">
        <i class="dot-red" />
        <i class="dot-yellow" />
        <i class="dot-green" />
      </span>
      <span class="terminal-title">{{ title || 'Claude Code' }}</span>
    </div>
    <div class="terminal-screen">
      <slot />
    </div>
  </div>
</template>

<script setup lang="ts">
defineProps<{ title?: string }>()
</script>

<style scoped>
.terminal {
  border-radius: 6px;
  overflow: hidden;
  margin: 24px 0;
  border: 1px solid #334155;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15);
}

.terminal-chrome {
  background: #1E293B;
  padding: 10px 16px;
  display: flex;
  align-items: center;
}

.terminal-dots {
  display: flex;
  gap: 6px;
}

.terminal-dots i {
  display: block;
  width: 11px;
  height: 11px;
  border-radius: 50%;
}

.dot-red { background: #EF4444; }
.dot-yellow { background: #F59E0B; }
.dot-green { background: #22C55E; }

.terminal-title {
  margin-left: 14px;
  font-size: 12px;
  color: #94A3B8;
  font-family: 'IBM Plex Sans', -apple-system, sans-serif;
  user-select: none;
}

.terminal-screen {
  background: #0F172A;
  padding: 20px 24px;
  font-family: 'JetBrains Mono', 'Fira Code', monospace;
  font-size: 13px;
  line-height: 1.7;
  color: #CBD5E1;
  overflow-x: auto;
}
</style>
