---
paths: "**/*.{ts,tsx,js,jsx,vue,svelte,css,scss}"
version: "1.0.0"
---
<!-- keel:generated -->

# Frontend

Rules for building accessible, performant, maintainable user interfaces.

## Component Design

- Components do ONE thing. If a component fetches data AND renders AND handles interactions, split it.
- Separate data-fetching (container) from presentation (pure) components.
- Keep components under 150 lines. Extract sub-components when they grow.
- Props should be the minimal set needed. Don't pass entire objects when you only need two fields.

## State Management

- Local state first. Only lift state up when siblings need it.
- URL state for anything the user should be able to bookmark or share (filters, pagination, search).
- Server state (React Query, SWR, etc.) for data from APIs. Don't put API responses in global state.
- Global state (Redux, Zustand, etc.) ONLY for truly app-wide concerns (auth, theme, feature flags).
- If you're not sure where state belongs: start local, move it up only when forced.

## Accessibility

- Every interactive element must be keyboard accessible (Tab, Enter, Escape, Arrow keys).
- Images need `alt` text. Decorative images use `alt=""`.
- Form inputs need associated `<label>` elements. Placeholders are not labels.
- Use semantic HTML (`<nav>`, `<main>`, `<article>`, `<button>`) over generic `<div>` with roles.
- Color must not be the only means of conveying information. Add text, icons, or patterns.
- Test with keyboard-only navigation. If you can't complete the flow without a mouse, it's broken.

## Performance

- Lazy load routes and heavy components. Don't load the settings page when the user is on the homepage.
- Images: use appropriate formats (WebP/AVIF), include width/height attributes, lazy load below-the-fold images.
- Avoid layout shifts: reserve space for dynamic content, set explicit dimensions on media.
- Memoize expensive computations and callbacks only when profiling shows a bottleneck — don't premature-optimize.
- Bundle size: check what you're importing. `import { debounce } from 'lodash'` pulls the entire library — use `import debounce from 'lodash/debounce'` or a smaller alternative.

## Styling

- Follow the project's existing convention (CSS modules, Tailwind, styled-components, etc.).
- Don't mix styling approaches in the same project without a clear boundary.
- Use design tokens / CSS variables for colors, spacing, and typography — never hardcode values.
- Responsive by default. Mobile-first media queries.

## Forms

- Validate on submit, not on every keystroke (unless explicitly required by UX spec).
- Show error messages next to the field that has the error, not just at the top of the form.
- Preserve user input on validation failure. Never clear the form.
- Disable the submit button while the request is in flight. Show loading state.
- Handle all states: empty, loading, error, success.

## Error & Loading States

Every component that depends on async data must handle:
1. **Loading** — Skeleton or spinner (not blank screen)
2. **Error** — Clear message with retry option
3. **Empty** — Helpful message, not blank space
4. **Success** — The actual content

Never show a blank screen for any state.
