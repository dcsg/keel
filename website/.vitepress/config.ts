import { defineConfig } from 'vitepress'
import { withMermaid } from 'vitepress-plugin-mermaid'

export default withMermaid(defineConfig({
  title: 'Keel',
  description: 'The governance layer for agentic engineering — govern the full cycle from requirements through execution to verification.',
  base: '/',
  cleanUrls: true,

  head: [
    ['link', { rel: 'icon', href: '/favicon.ico' }],
    ['link', { rel: 'preconnect', href: 'https://fonts.googleapis.com' }],
    ['link', { rel: 'preconnect', href: 'https://fonts.gstatic.com', crossorigin: '' }],
    ['link', { href: 'https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;600;700&family=IBM+Plex+Sans:wght@400;500;600&family=JetBrains+Mono:wght@400;500&display=swap', rel: 'stylesheet' }],
    ['meta', { name: 'robots', content: 'index, follow' }],
    ['meta', { property: 'og:type', content: 'website' }],
    ['meta', { property: 'og:site_name', content: 'Keel' }],
    ['meta', { property: 'og:image', content: '/og-image.png' }],
    ['meta', { name: 'twitter:card', content: 'summary_large_image' }],
  ],

  sitemap: {
    hostname: 'https://keel.dcsg.me'
  },

  themeConfig: {
    logo: '/logo.svg',
    siteTitle: 'Keel',

    nav: [
      { text: 'Guides', link: '/guides/solo-engineer' },
      { text: 'How It Works', link: '/governance/chain' },
      { text: 'Reference', link: '/commands/' },
      {
        text: 'GitHub',
        link: 'https://github.com/dcsg/keel',
      },
    ],

    sidebar: [
      {
        text: 'Get Started',
        items: [
          { text: 'What is Keel?', link: '/what-is-keel' },
          { text: 'Getting Started', link: '/getting-started' },
          { text: 'Philosophy', link: '/philosophy' },
        ],
      },
      {
        text: 'For You',
        items: [
          { text: 'Solo Engineers', link: '/guides/solo-engineer' },
          { text: 'Teams', link: '/guides/teams' },
          { text: 'Multi-Project', link: '/guides/multi-project' },
        ],
      },
      {
        text: 'How It Works',
        items: [
          { text: 'Governance Chain', link: '/governance/chain' },
          { text: 'Agents', link: '/agents' },
          { text: 'Quality Gates', link: '/governance/gates' },
          { text: 'Compiled Directives', link: '/governance/compile' },
          { text: 'Drift Detection', link: '/governance/drift' },
          { text: 'Governance Review', link: '/commands/review-governance' },
          { text: 'Configurable Features', link: '/governance/features' },
        ],
      },
      {
        text: 'Project Setup',
        items: [
          { text: 'Greenfield Projects', link: '/guides/greenfield' },
          { text: 'Existing Projects', link: '/guides/brownfield' },
          { text: 'Monorepos', link: '/guides/monorepo' },
          { text: 'Natural Language', link: '/natural-language' },
        ],
      },
      {
        text: 'Experiments',
        items: [
          { text: 'Governance Checkpoint', link: '/experiments/governance-checkpoint' },
        ],
      },
      {
        text: 'Reference',
        items: [
          { text: 'Commands', link: '/commands/' },
          { text: 'Rule Packs', link: '/rules/' },
          { text: 'FAQ', link: '/faq' },
        ],
      },
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/dcsg/keel' },
    ],

    footer: {
      message: 'Released under the Elastic License 2.0. Free to use, not for resale.',
    },

    search: {
      provider: 'local',
    },
  },
}))
