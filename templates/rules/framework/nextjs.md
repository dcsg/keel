---
paths: "**/*.{ts,tsx,js,jsx}"
---

# Next.js

Rules for building Next.js applications with the App Router.

## App Router Conventions

- Use the App Router (`app/` directory), not the Pages Router, unless migrating legacy code.
- Server Components are the default. Only add `'use client'` when the component needs browser APIs, event handlers, or React hooks with state.
- Keep `'use client'` boundaries as low as possible in the component tree. Don't make a whole page client-side for one interactive button.

## Data Fetching

- Fetch data in Server Components using `async` functions. No `useEffect` for initial data loads.
- Use React Server Components for data that doesn't change based on user interaction.
- Use `fetch()` with Next.js caching options for API calls in Server Components.
- Client-side data fetching (SWR, React Query) only for: real-time data, user-specific interactive data, or data that changes based on client state.

```tsx
// GOOD — Server Component fetches data
async function OrderPage({ params }: { params: { id: string } }) {
    const order = await getOrder(params.id)
    return <OrderDetails order={order} />
}

// BAD — unnecessary client component for static data
'use client'
function OrderPage({ params }) {
    const [order, setOrder] = useState(null)
    useEffect(() => { fetchOrder(params.id).then(setOrder) }, [])
}
```

## Server Actions

- Use Server Actions for form submissions and mutations. Don't create API routes for simple CRUD.
- Define Server Actions in separate files with `'use server'` at the top.
- Validate inputs in Server Actions — they're public endpoints, not trusted internal calls.
- Use `revalidatePath()` or `revalidateTag()` after mutations to update cached data.

## Route Organization

```
app/
├── (marketing)/          # route group, no URL impact
│   ├── page.tsx          # homepage
│   └── about/page.tsx
├── (app)/                # authenticated app section
│   ├── layout.tsx        # shared app layout with auth
│   ├── dashboard/page.tsx
│   └── orders/
│       ├── page.tsx      # order list
│       └── [id]/page.tsx # order detail
├── api/                  # API routes (only for webhooks, external integrations)
├── layout.tsx            # root layout
└── error.tsx             # global error boundary
```

## Layouts & Loading

- Use `layout.tsx` for shared UI that persists across navigations (nav, sidebar).
- Use `loading.tsx` for streaming/suspense loading states per route segment.
- Use `error.tsx` for error boundaries per route segment.
- Layouts don't re-render on navigation — don't put data that changes per page in layouts.

## Metadata & SEO

- Export `metadata` or `generateMetadata()` from every page.
- Include: title, description, Open Graph tags at minimum.
- Use `generateStaticParams()` for static generation of dynamic routes.

## Performance

- Use `next/image` for all images — never raw `<img>` tags.
- Use `next/link` for all internal navigation — never raw `<a>` tags.
- Use dynamic imports (`next/dynamic`) for heavy client components that aren't needed immediately.
- Use route groups to split layouts and avoid loading unnecessary UI.

## Environment Variables

- Server-only variables: no prefix (accessed in Server Components, Server Actions, API routes).
- Client-exposed variables: `NEXT_PUBLIC_` prefix. Only use for truly public values.
- Never put secrets in `NEXT_PUBLIC_` variables.
- Validate environment variables at build/startup time, not at runtime in business logic.
