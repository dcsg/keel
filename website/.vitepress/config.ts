import { defineConfig } from 'vitepress'

export default defineConfig({
  title: 'Keel',
  description: 'The context engine for Claude Code',
  cleanUrls: true,

  head: [
    ['link', { rel: 'icon', href: '/favicon.ico' }],
  ],

  themeConfig: {
    logo: '/logo.svg',
    siteTitle: 'Keel',

    nav: [
      { text: 'Docs', link: '/getting-started' },
      { text: 'Commands', link: '/commands/' },
      { text: 'Rules', link: '/rules/' },
      {
        text: 'GitHub',
        link: 'https://github.com/dcsg/keel',
      },
    ],

    sidebar: [
      {
        text: 'Introduction',
        items: [
          { text: 'What is Keel?', link: '/what-is-keel' },
          { text: 'Getting Started', link: '/getting-started' },
        ],
      },
      {
        text: 'Commands',
        items: [
          { text: 'Overview', link: '/commands/' },
          { text: '/keel:init', link: '/commands/init' },
          { text: '/keel:context', link: '/commands/context' },
          { text: '/keel:plan', link: '/commands/plan' },
          { text: '/keel:status', link: '/commands/status' },
          { text: '/keel:intake', link: '/commands/intake' },
          { text: '/keel:migrate', link: '/commands/migrate' },
        ],
      },
      {
        text: 'Rule Packs',
        items: [
          { text: 'Overview', link: '/rules/' },
          { text: 'Base Rules', link: '/rules/base' },
          { text: 'Language Rules', link: '/rules/language' },
          { text: 'Framework Rules', link: '/rules/framework' },
          { text: 'Custom Rules', link: '/rules/custom' },
        ],
      },
      {
        text: 'Guides',
        items: [
          { text: 'Greenfield Projects', link: '/guides/greenfield' },
          { text: 'Existing Projects', link: '/guides/brownfield' },
          { text: 'Monorepos', link: '/guides/monorepo' },
          { text: 'Teams', link: '/guides/teams' },
        ],
      },
      {
        text: 'More',
        items: [
          { text: 'Migration from dof', link: '/migration' },
          { text: 'FAQ', link: '/faq' },
          { text: 'Philosophy', link: '/philosophy' },
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
})
