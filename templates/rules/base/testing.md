---
paths: "**/*.{go,ts,tsx,js,jsx,py,rb,php,rs,java,kt}"
version: "0.1.0"
---
<!-- keel:generated -->

<governance_checkpoint>
Before modifying any file, pause and verify:
1. List which rules from this file apply to the change you are about to make.
2. Check if the change tests implementation details instead of behavior, or skips edge cases.
3. If multiple rules conflict, state the conflict before proceeding.
After receiving tool results (test output, lint output, build errors), re-check:
1. Verify the result complies with the rules you identified above.
2. If it does not, fix the violation before taking any other action.
3. Do not chain corrections — verify each step against these rules before proceeding.
</governance_checkpoint>

# Testing

Rules for writing reliable, maintainable tests. Every feature and bugfix must have tests.

## Critical

- NEVER write production code before a failing test. If you did, delete it and restart with TDD. This is not optional.
- NEVER assert on mock existence or mock call counts as a substitute for testing behavior. Testing that a mock was called proves nothing about the code under test.
- MUST cover every feature and bugfix with tests. Untested code is unfinished code.
- NEVER write a test whose assertion is guaranteed to pass regardless of the code under test. If removing the function being tested would still leave the test green, the test is tautological — rewrite it with an assertion that would fail on a plausible bug.

## Standards

- Follow Red-Green-Refactor: write one failing test → confirm it fails for the right reason → write the minimum code to pass → refactor with tests green.
- One behavior per test. "Validates email and saves user" is two tests.
- Name tests to document behavior: `rejects empty email with validation error`, `retries failed operations up to 3 times`. If you need "and" in the name, split the test.
- Test what the code DOES, not how it does it. Tests coupled to implementation details break on every refactor.
- Only mock: external services (APIs, third-party), I/O operations, and non-deterministic behavior (time, randomness). Use real implementations everywhere else.
- Mock the complete data structure, not just the fields your test happens to need. Partial mocks hide structural assumptions.

## Practices

- Test all paths: happy path, invalid input (null, empty, wrong type, too large), boundary conditions (zero, one, max), and error paths (timeout, permission denied).
- If a test requires deep mocking or access to private internals, the code has a design problem. Hard to test = too many dependencies or wrong abstraction boundary. Fix the code, then test it.

## Critical

- NEVER write production code before a failing test.
- NEVER test mock behavior — test what the code actually does.
