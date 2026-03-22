---
paths: "**/*.{go,ts,tsx,js,jsx,py,rb,php,rs,java,kt}"
version: "0.1.0"
---
<!-- keel:generated -->

<governance_checkpoint>
Before modifying any file, pause and verify:
1. List which rules from this file apply to the change you are about to make.
2. Check if the change violates layer boundaries, dependency direction, or bounded context isolation.
3. If multiple rules conflict, state the conflict before proceeding.
After receiving tool results (test output, lint output, build errors), re-check:
1. Verify the result complies with the rules you identified above.
2. If it does not, fix the violation before taking any other action.
3. Do not chain corrections — verify each step against these rules before proceeding.
</governance_checkpoint>

# Architecture

Enable this pack for projects with complex domain logic, multiple bounded contexts, or business rules beyond simple CRUD.

## Critical

- NEVER import from an outer layer into an inner one. Domain must not import from application, infrastructure, or transport. Application must not import from infrastructure or transport. Dependencies always point inward.
- NEVER share domain entities between bounded contexts. Each context defines its own representation of shared concepts.
- MUST place repository interfaces in the domain layer and implementations in the infrastructure layer.

## Standards

Organize code into layers with strict dependency direction:

```
Domain (innermost)    → entities, value objects, domain events, repository interfaces
Application           → use cases, DTOs, application services
Infrastructure        → database, external APIs, file system, queues
Transport (outermost) → HTTP handlers, CLI, gRPC, GraphQL resolvers
```

- Bounded contexts communicate through application services, domain events, or explicit anti-corruption layers — never through direct domain imports.
- Code names (classes, methods, variables) MUST match the domain language used by stakeholders. If the business says "shipment", don't call it "delivery".
- Use value objects for domain concepts instead of primitives: `Money` over `float64`, `EmailAddress` over `string`, `DateRange` over two dates.
- All modifications to an aggregate go through the aggregate root. External code never modifies internal entities directly. Reference other aggregates by ID, not by object reference.
- Use cases orchestrate domain objects for one business operation. Business logic belongs in domain objects, not in the use case.

## Practices

- Keep aggregates small. If loading an aggregate requires many joins or sub-queries, the boundary is wrong.
- Domain events are past-tense facts: `OrderPlaced`, `PaymentReceived`. They carry only the data consumers need — not the full aggregate state.
- When integrating with external systems: define your own domain model, create adapters that translate, and ensure the rest of the codebase never knows the external format.
- Prefer explicit anti-corruption layers over letting external data structures slowly leak into your domain model.
- Consider extracting a `ddd.md` or project-level CLAUDE.md section to document the specific bounded contexts and aggregates for this project.

## Critical

- NEVER import from an outer layer into an inner layer — dependencies point inward only.
- NEVER share domain entities between bounded contexts.
