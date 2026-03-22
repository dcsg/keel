---
layout: home

hero:
  name: "keel"
  text: "The governance layer for agentic engineering."
  tagline: Your coding standards, enforced. Your decisions, remembered. Every session, every engineer, every project.
  actions:
    - theme: brand
      text: Get Started — 5 minutes
      link: /getting-started
    - theme: alt
      text: What is Keel?
      link: /what-is-keel

features:
  - title: Natural language, not commands
    details: "Say 'what's our status?' and Claude shows the governance dashboard. Say 'write a PRD for X' and Claude generates structured requirements. Say 'does the implementation match the spec?' and Claude runs drift detection. You talk. keel handles the rest."
  - title: Enforced standards
    details: "Coding standards install to .claude/rules/ and fire automatically — path-conditional, so Go rules only fire on .go files. No drift between engineers. No reminding. The standard is the same whether it's your best engineer or your newest."
  - title: Governance chain
    details: "PRD → spec → artifacts → plan → execute → drift detection. Each step feeds the next. Each must be accepted before the next begins. Each can be verified against the original intent. The full cycle, traceable."
  - title: Compiled directives
    details: "Tell Claude 'save this decision' and it captures an ADR. Tell Claude 'compile governance' and it extracts directives into governance.md — auto-loaded every session. Update the decision, recompile. One source of truth."
  - title: Quality gates
    details: "Critical findings block progression automatically. A hardcoded JWT secret stops the build until resolved. Overrides are logged with git identity — you see who approved what, on which project. No silent failures."
  - title: Zero dependencies
    details: "Every file is .md or .yaml. No build step, no runtime, no daemon, no lock-in. curl | bash to install. If you stop using keel, the files stay — plain markdown you own, read, edit, and version-control."
---

Claude has memory. It doesn't have governance. Every session starts without standards — and decisions made yesterday get contradicted today.

**Solo engineers** use keel to stop re-explaining their architecture every session. **Team leads** use it to enforce standards across every engineer's Claude — so code review catches design issues, not formatting. **Consultancies** use it to install their methodology on day one of every client project.
