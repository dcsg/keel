---
paths: "**/*.{ts,tsx,js,jsx}"
version: "0.1.0"
---
<!-- keel:generated -->

<governance_checkpoint>
Before modifying any file, pause and verify:
1. List which rules from this file apply to the change you are about to make.
2. Check if the change leaks secrets via NEXT_PUBLIC_, misuses client/server boundaries, or skips next/image.
3. If multiple rules conflict, state the conflict before proceeding.
After receiving tool results (test output, lint output, build errors), re-check:
1. Verify the result complies with the rules you identified above.
2. If it does not, fix the violation before taking any other action.
3. Do not chain corrections — verify each step against these rules before proceeding.
</governance_checkpoint>

# Next.js

Rules for building Next.js applications with the App Router.

## Critical

- NEVER put secrets in `NEXT_PUBLIC_` variables — they are embedded in the client bundle and visible to anyone. Server-only values use no prefix.
- NEVER use raw `<img>` tags — use `next/image`. Raw images skip optimization, lazy loading, and layout shift prevention that `next/image` provides.
- NEVER use raw `<a>` tags for internal navigation — use `next/link`. Raw anchors trigger a full page reload.

## Standards

- Server Components are the default. Only add `'use client'` when the component needs browser APIs, event handlers, or React hooks with state. Keep `'use client'` boundaries as low as possible — don't make an entire page client-side for one interactive button.
- Fetch data in Server Components using `async` functions. No `useEffect` for initial data loads — that pattern forces a client render cycle for data that could be server-rendered.
- Use Server Actions for form submissions and mutations. Don't create API routes for simple CRUD. Validate inputs in Server Actions — they are public endpoints.
- Call `revalidatePath()` or `revalidateTag()` after mutations that change cached data.
- Export `metadata` or `generateMetadata()` from every page: title, description, and Open Graph tags at minimum.
- Validate environment variables at startup, not inside business logic. A missing env var should fail the build, not cause a runtime error for the first user who triggers that code path.

## Practices

- Use `loading.tsx` for streaming/suspense states per route segment. Use `error.tsx` for error boundaries per route segment.
- Layouts don't re-render on navigation — don't put per-page data in layouts.
- Use `generateStaticParams()` for static generation of dynamic routes where content is known at build time.
- Use dynamic imports (`next/dynamic`) for heavy client components that aren't needed on initial load.

## Critical

- NEVER put secrets in `NEXT_PUBLIC_` variables.
- NEVER use raw `<img>` or `<a>` — use `next/image` and `next/link`.
