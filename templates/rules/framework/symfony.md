---
paths: "**/*.php"
---
<!-- keel:generated -->

# Symfony

Rules for building Symfony applications.

## Architecture

- Follow Symfony's directory conventions: `src/Controller/`, `src/Entity/`, `src/Repository/`, `src/Service/`.
- For complex domains, organize by bounded context: `src/Order/`, `src/Payment/`, etc.
- Controllers are thin — validate, call service, return response.
- Use services for business logic. Register them with autowiring.

## Dependency Injection

- Use constructor injection exclusively. Never call the container directly in services.
- Type-hint interfaces in constructors when multiple implementations exist.
- Use `#[Autowire]` attribute for scalar parameters or named services.
- Services are private by default. Only make them public if they must be accessed from the container directly.

```php
// BAD — service location
class OrderService {
    public function __construct(private ContainerInterface $container) {}

    public function process(): void {
        $mailer = $this->container->get(MailerInterface::class);
    }
}

// GOOD — constructor injection
class OrderService {
    public function __construct(
        private MailerInterface $mailer,
        private OrderRepository $orders,
    ) {}
}
```

## Doctrine ORM

- Define entities with PHP attributes, not XML or YAML mappings.
- Use the repository pattern: custom repositories extend `ServiceEntityRepository`.
- Always use the `EntityManager` through repositories, not directly in controllers.
- Use DQL or QueryBuilder for complex queries. Avoid raw SQL unless performance requires it.
- Define indexes on columns used in WHERE and ORDER BY clauses.
- Use migrations for ALL schema changes: `php bin/console make:migration`.

## Controllers

- Use PHP attributes for routing: `#[Route('/orders', name: 'order_')]`.
- Return typed responses: `JsonResponse`, `Response`, `RedirectResponse`.
- Use `#[MapRequestPayload]` or Form types for request deserialization and validation.
- Group related routes in one controller. One controller per resource/entity.

```php
#[Route('/api/orders')]
class OrderController extends AbstractController
{
    #[Route('', methods: ['GET'])]
    public function list(OrderRepository $orders): JsonResponse
    {
        return $this->json($orders->findRecent());
    }

    #[Route('/{id}', methods: ['GET'])]
    public function show(Order $order): JsonResponse
    {
        return $this->json($order);
    }
}
```

## Validation

- Use Symfony's validator with constraint attributes on entities/DTOs.
- Validate DTOs, not entities directly when handling external input.
- Create custom constraints for domain-specific validation rules.

## Events & Messaging

- Use Symfony Messenger for async operations: emails, notifications, external API calls.
- Messages (commands/events) are simple DTOs. Handlers contain the logic.
- Use `#[AsMessageHandler]` attribute on handler classes.
- Configure transports in `messenger.yaml`. Use `sync` transport for development, `doctrine` or `amqp` for production.

## Security

- Use Symfony Security component for authentication and authorization.
- Define voters for complex authorization logic: `#[IsGranted('ORDER_VIEW', subject: 'order')]`.
- Never check roles in business logic — use voters and access control.

## Testing

- Use `WebTestCase` for functional tests with the kernel booted.
- Use `KernelTestCase` for integration tests with the container.
- Use PHPUnit with Symfony's test utilities.
- Reset the database between tests with `dama/doctrine-test-bundle` or fixtures.
- Test through HTTP for controllers, directly for services.

## Configuration

- Use environment variables for environment-specific values.
- Use `config/packages/` YAML files for service and bundle configuration.
- Use `#[When(env: 'dev')]` or conditional service loading for environment-specific services.
