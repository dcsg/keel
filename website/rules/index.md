# Rule Packs

Keel's rule packs are guardrails against specific mistakes Claude makes — not a collection of best-practice opinions. Each pack targets a category of error: hallucinated APIs, placeholder code, race conditions, tautological tests, timing attacks. Architecture opinions belong in ADRs (or archway, if you use it). Rule packs are about correctness.

Each rule is a single `.md` file installed to `.claude/rules/` with `paths:` frontmatter so it only activates on relevant files. All packs are at version 0.1.0.

## Tiers

| Tier | What | Scope |
|------|------|-------|
| **Base** | Universal coding standards | Matched file types |
| **Language** | Language-specific patterns | `**/*.{ext}` |
| **Framework** | Framework conventions | Framework file patterns |

## Phrasing system

Every rule in every pack follows a four-level phrasing system:

| Level | Meaning |
|-------|---------|
| `NEVER` | Hard prohibition — violation is always wrong |
| `MUST` | Required — omission is always wrong |
| `Prefer` | Strong default — deviate only with explicit justification |
| `Consider` | Contextual suggestion — apply when it makes the code clearer |

`NEVER` and `MUST` rules are enforced as invariants. `Prefer` and `Consider` rules are guidance Claude applies with judgment.

## All Packs

### Base (enabled by default)

| Pack | Enforces | Paths |
|------|---------|-------|
| [code-quality](/rules/base#code-quality) | Hallucinated API prevention, placeholder detection, codebase consistency, race conditions, edge cases, over-engineering prevention, naming, size limits | `**/*.{go,ts,tsx,js,jsx,py,rb,php,rs,java,kt,swift,c,cpp,cs}` |
| [testing](/rules/base#testing) | Tautological test detection, behavior-focused tests, mock boundaries, TDD | `**/*.{go,ts,tsx,js,jsx,py,rb,php,rs,java,kt}` |
| [security](/rules/base#security) | Timing attack prevention, error exposure, input validation, parameterized queries, no secret logging | `**/*.{go,ts,tsx,js,jsx,py,rb,php,rs,java,kt,sql}` |
| [error-handling](/rules/base#error-handling) | Typed errors, context enrichment, no silent catches | `**/*.{go,ts,tsx,js,jsx,py,rb,php,rs,java,kt}` |

### Base (opt-in)

| Pack | Enforces | Paths |
|------|---------|-------|
| [frontend](/rules/base#frontend) | Component patterns, a11y, state management — seo.md owns alt text | `**/*.{ts,tsx,js,jsx,vue,svelte,css,scss}` |
| [architecture](/rules/base#architecture) | Layer boundary correctness, import discipline — if you use archway, skip this pack | `**/*.{go,ts,tsx,js,jsx,py,rb,php,rs,java,kt}` |
| [api](/rules/base#api) | REST/GraphQL/gRPC conventions, versioning, error shapes — security.md owns validation and error exposure | `**/*.{go,ts,tsx,js,jsx,py,rb,php,rs,java,kt}` |
| [database](/rules/base#database) | Query hygiene, migration safety, index discipline — database.md owns index rules across all packs | `**/*.{go,ts,tsx,js,jsx,py,rb,php,rs,java,kt,sql}` |
| [observability](/rules/base#observability) | Structured logging, tracing, metrics | `**/*.{go,ts,tsx,js,jsx,py,rb,php,rs,java,kt}` |
| [seo](/rules/base#seo) | Technical SEO, structured data, Core Web Vitals, alt text — owns alt text across all packs | `**/*.{html,tsx,jsx,vue,svelte,astro,md,mdx}` |

### Language

| Pack | Scope |
|------|-------|
| [go](/rules/language#go) | `**/*.go` |
| [typescript](/rules/language#typescript) | `**/*.{ts,tsx}` |
| [python](/rules/language#python) | `**/*.py` |
| [php](/rules/language#php) | `**/*.php` |

### Framework

| Pack | Scope |
|------|-------|
| [chi](/rules/framework#chi) | `**/*.go` |
| [nextjs](/rules/framework#nextjs) | `**/*.{ts,tsx,js,jsx}` |
| [laravel](/rules/framework#laravel) | `**/*.php` |
| [symfony](/rules/framework#symfony) | `**/*.php` |
| [rails](/rules/framework#rails) | `**/*.rb` |
| [django](/rules/framework#django) | `**/*.py` |

## Path scoping

Each rule pack declares a `paths:` glob in its frontmatter. Claude only loads the rule when editing a file that matches. This means:

- The Go rule pack never fires when you're editing TypeScript
- The security pack fires on both `.go` and `.sql` files (SQL is a security surface)
- The SEO pack fires on `.html`, `.tsx`, `.vue`, `.astro`, and `.md` but not `.go`

Path scoping keeps context lean — Claude loads only the rules relevant to the file being edited.

Framework packs declare a `parent:` field pointing to their language pack. Installing `chi` also ensures `go` is active. Installing `nextjs` ensures `typescript` is active.

## Customization

See [Custom Rules](/rules/custom) for toggling packs, extending existing rules, and creating new rule topics.
