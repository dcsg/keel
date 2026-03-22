# Plan: Website + Launch — keel v4

## Overview
**Task:** Implement the v4 website, apply persona copy, SEO setup, and prepare launch content
**Source:** Website Rewrite, SEO Audit, Persona Copy Optimization, Visual Identity Brief
**Total Phases:** 4
**Created:** 2026-03-20

## Progress

| Phase | Theme | Status | Updated |
|-------|-------|--------|---------|
| 1 | VitePress Implementation | not started | — |
| 2 | Persona Copy + Content | not started | — |
| 3 | SEO Technical Setup | not started | — |
| 4 | Final Polish + README | not started | — |

**IMPORTANT:** Update this table as phases complete.

## Context

### What exists
- Website design direction locked: Variant B (Content-Dense & Technical)
- Full page rewrites drafted in Obsidian (Website Rewrite — 2026-03-20.md)
- Persona copy adjustments identified (Persona Copy Optimization — 2026-03-20.md)
- SEO audit complete with 90-day plan (SEO Audit — 2026-03-20.md)
- Visual identity brief with all tokens (Visual Identity Brief — 2026-03-17.md)
- Brand positioning, voice guide, ICPs all locked

### Design tokens (from Visual Identity Brief)
- Fonts: Space Grotesk 700/600 (headings), IBM Plex Sans 400 (body), JetBrains Mono 400 (code)
- Typography: h1 36px/1.15, h2 30px/1.2, h3 24px/1.25, body 16px/1.65, code 14px/1.5
- Colors: Slate #2D3748, Stone #A0936D, Teal #0D9488 (interactive only), Deep Slate #0F172A
- Dark mode: bg #0F172A, surface #1E293B, text #F1F5F9, accent #2DD4BF
- No emoji, no gradients, max border-radius 6px

### Source documents in Obsidian (10 - Projects/keel/)
- Website Rewrite — 2026-03-20.md (page-by-page content)
- Persona Copy Optimization — 2026-03-20.md (15 surgical adjustments)
- SEO Audit — 2026-03-20.md (meta tags, structured data, site structure)
- Visual Identity Brief — 2026-03-17.md (tokens, constraints)
- Brand Voice Guide.md (Precise, Direct, Authoritative, Forward)

---

## Phase 1: VitePress Implementation

**Goal:** Apply Variant B design + v4 content to the actual VitePress site. All pages functional with correct tokens.

### Tasks

#### 1.1 — Update VitePress config
- Update `website/.vitepress/config.ts` with:
  - New sidebar structure (Introduction, Governance, Commands, Rule Packs, Guides, More)
  - Expanded commands list (add spec, spec-artifacts, drift, compile)
  - New "Governance" section (chain, gates, compile, drift)
  - SEO description: "The governance layer for agentic engineering — enforce coding standards, persist decisions, verify implementation."
  - Move Philosophy from More to Introduction
  - Move Natural Language from Introduction to Guides
  - Keep `base: '/keel/'` for now (change to '/' when deploying to keel.dcsg.me)

**Files:** `website/.vitepress/config.ts`

#### 1.2 — Custom VitePress theme for brand tokens
- Create `website/.vitepress/theme/` with custom CSS overriding VitePress defaults
- Apply typography: Space Grotesk headings, IBM Plex Sans body, JetBrains Mono code
- Apply colors: Slate, Stone, Teal palette for both light and dark mode
- Apply constraints: no rounded corners >6px, teal for interactive only
- Import Google Fonts

**Files:** `website/.vitepress/theme/index.ts`, `website/.vitepress/theme/custom.css`

#### 1.3 — Rewrite index.md (homepage)
- Apply Variant B homepage layout via VitePress home layout
- Hero: lowercase "keel", category claim, locked tagline
- Features grid: governance chain, enforced standards, compiled directives, specialist agents, quality gates, zero dependencies
- No emoji icons
- Apply persona copy adjustments from optimization doc

**Files:** `website/index.md`

#### 1.4 — Rewrite what-is-keel.md
- Full content from Website Rewrite doc
- All 10 sections: manifesto, problem, fix, full cycle, governance loop, compiled directives, quality gates, dashboard, for teams, Claude Code only
- Apply persona adjustments: trigger moments, expanded "For teams" (Elena), new "Across projects" (Ravi)
- Terminal mocks for code examples, gates, dashboard

**Files:** `website/what-is-keel.md`

#### 1.5 — Rewrite philosophy.md
- 8 principles from Website Rewrite doc
- Led by "Governance over context"
- New principles: "Decisions compile into enforcement", "Traceability over trust", "Compound consistency"

**Files:** `website/philosophy.md`

#### 1.6 — Rewrite getting-started.md
- Updated from Website Rewrite doc
- Install → init → new vs existing → file tree → hooks table (9 hooks) → what to do next
- Apply persona adjustments: "Start the governance chain" as primary next step

**Files:** `website/getting-started.md`

#### 1.7 — Rewrite faq.md
- Updated questions from Website Rewrite doc
- New FAQs: governance chain, drift detection, quality gates, /keel:compile
- Apply persona objection handling copy
- Enhanced CLAUDE.md comparison with benefit translations

**Files:** `website/faq.md`

#### 1.8 — Add new command pages
- Create pages for v4 commands not yet documented:
  - `website/commands/spec.md`
  - `website/commands/spec-artifacts.md`
  - `website/commands/drift.md`
  - `website/commands/compile.md`
- Each page: description, arguments, what it does, example output

**Files:** `website/commands/spec.md`, `website/commands/spec-artifacts.md`, `website/commands/drift.md`, `website/commands/compile.md`

#### 1.9 — Add governance guide pages
- Create the new "Governance" sidebar section pages:
  - `website/governance/chain.md` — the full PRD → spec → artifacts → plan → execute → drift chain
  - `website/governance/gates.md` — quality gates explanation + configuration
  - `website/governance/compile.md` — compiled directives from ADRs + invariants + guidelines
  - `website/governance/drift.md` — drift detection explanation + report format

**Files:** `website/governance/chain.md`, `website/governance/gates.md`, `website/governance/compile.md`, `website/governance/drift.md`

### Completion promise
After phase 1: all website pages updated with v4 content, Variant B design applied via custom theme, new command and governance pages created. Site builds and serves locally.

---

## Phase 2: Persona Copy + Content

**Goal:** Apply all 15 persona copy adjustments and ensure every page passes the voice check.

### Tasks

#### 2.1 — Apply homepage persona adjustments
- Extended tagline: "Every session, every engineer, every project"
- "Who it's for" paragraph naming each persona
- Marcus trigger moment in the hero area
- Elena signal in features or below features

**Files:** `website/index.md`

#### 2.2 — Apply what-is-keel persona adjustments
- Expanded "For teams" section with Elena's benefits (code review shifts, team consistency)
- New "Across projects" section for Ravi (repeatable methodology, per-client rules)
- Inline CTAs at decision points (after insight for Marcus, after teams for Elena, after projects for Ravi)
- Objection handling woven into natural flow

**Files:** `website/what-is-keel.md`

#### 2.3 — Apply FAQ persona adjustments
- Enhanced CLAUDE.md comparison with benefit translations per persona
- New FAQ: "How does keel work across multiple projects?" (Ravi)
- New FAQ: "How does keel interact with linters and CI?" (Elena)
- Trigger moment copy for each persona
- Closing CTA pair

**Files:** `website/faq.md`

#### 2.4 — Apply getting-started persona adjustments
- CTA: "Get Started — 5 minutes"
- "What to do next" section speaks to all three paths

**Files:** `website/getting-started.md`

#### 2.5 — Voice check all pages
- Read every page against the Brand Voice Guide
- Precise: specific mechanisms, not vague promises?
- Direct: leads with the point, no preamble?
- Authoritative: speaks from experience, no hedging?
- Forward: names what's coming, not what's comfortable?
- Flag and fix any violations

**Files:** all website pages

### Completion promise
After phase 2: every page speaks to all three ICPs with Marcus as primary. Objections handled. Trigger moments present. Voice consistent.

---

## Phase 3: SEO Technical Setup

**Goal:** Implement the technical SEO foundation from the SEO audit.

### Tasks

#### 3.1 — Meta tags
- Add per-page title and description meta tags (from SEO Audit Section 8)
- Add OG meta tags (og:title, og:description, og:image, og:type)
- Add Twitter card meta tags
- Add canonical URLs

**Files:** `website/.vitepress/config.ts`, per-page frontmatter

#### 3.2 — Sitemap and robots.txt
- Enable VitePress sitemap generation
- Create `website/public/robots.txt`
- Set hostname to `https://keel.dcsg.me` (ready for deployment)

**Files:** `website/.vitepress/config.ts`, `website/public/robots.txt`

#### 3.3 — Structured data
- Add JSON-LD SoftwareApplication schema to homepage
- Add JSON-LD FAQPage schema to FAQ
- Add JSON-LD Article schema template for blog posts (future)

**Files:** `website/.vitepress/config.ts` or per-page head config

#### 3.4 — Site structure
- Ensure URL hierarchy matches SEO audit recommendation
- Flat architecture (3 clicks max to any page)
- Internal linking between related pages
- Breadcrumbs if VitePress supports them

**Files:** `website/.vitepress/config.ts`, all pages (internal links)

### Completion promise
After phase 3: site is SEO-ready. Meta tags, sitemap, robots.txt, structured data all in place. Ready for Google Search Console submission after deployment.

---

## Phase 4: Final Polish + README

**Goal:** Final pass on README, ensure consistency between README and website, clean up preview files.

### Tasks

#### 4.1 — README final pass
- Apply persona copy adjustments to README (same as website where applicable)
- Ensure command table matches website
- Ensure governance chain description is identical
- Voice check against Brand Voice Guide

**Files:** `README.md`

#### 4.2 — CLAUDE.md template final pass
- Ensure template references all v4 commands
- Verify command routing table is complete and current

**Files:** `templates/CLAUDE.md.tmpl`, `CLAUDE.md`

#### 4.3 — Clean up preview files
- Remove temporary HTML preview files from docs/:
  - `docs/brand-directions-compare.html`
  - `docs/brand-assets.html`
  - `docs/brand-logo-concepts.html`
  - `docs/website-preview.html`
  - `docs/website-variants.html`
  - `docs/website-variant-b-full.html`
- These were design exploration files, not production content

**Files:** delete 6 HTML files from docs/

#### 4.4 — Update soul.md
- Align with v4 positioning: governance layer for agentic engineering
- Update mission and core principles to match locked brand

**Files:** `docs/soul.md`

#### 4.5 — Final test run
- `bash test/run.sh` — all suites pass
- `cd website && npm run dev` — site builds and serves
- Manual review: click through every page, check all terminal mocks render, verify no broken links

#### 4.6 — Update Obsidian roadmap
- Mark all phases done
- Note launch coordination items remaining

**Files:** Obsidian `v4 Brand & Product Roadmap.md`

### Completion promise
After phase 4: README and website are consistent, voice-checked, persona-optimized, and SEO-ready. Preview files cleaned up. Ready to push and deploy.

---

## Notes

- All content comes from the Obsidian source documents — no inventing from scratch
- VitePress custom theme should be minimal — override colors and fonts, not the layout engine
- Dark mode: implement via VitePress's built-in dark mode toggle using the dark palette from the visual identity brief
- The 90-day content calendar (SEO audit) starts AFTER deployment — this plan covers the site itself, not the ongoing content
