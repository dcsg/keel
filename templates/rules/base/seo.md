---
paths: "**/*.{html,tsx,jsx,vue,svelte,astro,md,mdx}"
version: "0.1.0"
---
<!-- keel:generated -->

<governance_checkpoint>
Before modifying any file, pause and verify:
1. List which rules from this file apply to the change you are about to make.
2. Check if the change breaks meta tags, structured data, or crawlability.
3. If multiple rules conflict, state the conflict before proceeding.
After receiving tool results (test output, lint output, build errors), re-check:
1. Verify the result complies with the rules you identified above.
2. If it does not, fix the violation before taking any other action.
3. Do not chain corrections — verify each step against these rules before proceeding.
</governance_checkpoint>

# SEO

Rules for technical SEO: metadata, structured data, Core Web Vitals, and semantic markup.

## Critical

- NEVER render the same content at multiple URLs without a canonical tag. Duplicate content splits ranking signals — use `<link rel="canonical">` on every page.
- NEVER use non-descriptive page titles: "Page 1", "Untitled", or the site name alone. Every page title MUST be unique, descriptive, and 50-60 characters.
- MUST add `alt` text to every meaningful image. Decorative images use `alt=""`. Empty alt on meaningful images is an accessibility and indexability failure.

## Standards

- Every page needs a unique `<meta name="description">` of 120-160 characters that summarizes the page content. It doesn't affect rankings directly, but it determines click-through rate in search results.
- Use one `<h1>` per page. Heading hierarchy must be sequential: `<h1>` → `<h2>` → `<h3>`. Never skip levels (e.g., `<h1>` directly to `<h3>`).
- Use semantic HTML: `<article>`, `<section>`, `<nav>`, `<main>`, `<header>`, `<footer>`. Search engines use these landmarks to understand page structure.
- Add Open Graph tags to every page: `og:title`, `og:description`, `og:image`, `og:url`. `og:image` should be at least 1200x630px.
- Internal links MUST have descriptive anchor text: "View order details" not "click here". Generic anchor text provides no signal about the linked page's content.
- Ensure pages pass Core Web Vitals thresholds: LCP under 2.5s, CLS under 0.1, INP under 200ms. Layout shifts (CLS) are caused by unsized images and dynamically injected content.

## Practices

- Add structured data (JSON-LD) for content types that benefit from rich results: articles, products, FAQs, breadcrumbs, organizations. Place the `<script type="application/ld+json">` block in `<head>`.
- Canonical URLs must be absolute, not relative. `https://example.com/blog/post` not `/blog/post`.
- Keep URL slugs lowercase, hyphenated, and descriptive. Avoid query parameters in canonical URLs where possible.
- Paginated content: use `rel="next"` and `rel="prev"` where applicable, or ensure paginated pages have unique titles and meta descriptions.
- Add a `<link rel="sitemap">` in `<head>` and maintain an up-to-date sitemap.xml for large sites.

## Critical

- NEVER render duplicate content at multiple URLs without a canonical tag.
- MUST write unique, descriptive page titles for every page.
