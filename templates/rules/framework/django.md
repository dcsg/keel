---
paths: "**/*.py"
version: "1.0.0"
---
<!-- keel:generated -->

# Django

Rules for building Django applications.

## Architecture

- Follow Django's app-based architecture. Each app owns one domain concept.
- Apps should be loosely coupled. Minimize imports between apps — communicate through Django signals, service functions, or shared interfaces.
- Views are thin: validate input, call service/model, return response.
- For complex domains: create a `services.py` or `services/` module per app for business logic.

## Models

- Define all constraints in the model: validators, `unique`, `null`, `blank`, `default`, choices.
- Use `Meta` class for: ordering, indexes, unique constraints, verbose names.
- Add `__str__` to every model for admin and debugging.
- Use model managers for custom querysets: `objects = OrderManager()`.
- Add database indexes for fields used in filters and ordering.

```python
class Order(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='orders')
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.PENDING)
    total = models.DecimalField(max_digits=10, decimal_places=2)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']
        indexes = [models.Index(fields=['user', 'status'])]

    def __str__(self):
        return f"Order {self.pk} - {self.status}"
```

## Views

Keep views thin — validate input, call service/model, return response.

### Class-Based Views
- Use generic views (`ListView`, `DetailView`, `CreateView`) for standard CRUD.
- Override only the methods you need. Don't rewrite `get()` when `get_queryset()` suffices.

### Function-Based Views
- Acceptable for simple endpoints, API views, or when CBVs add unnecessary complexity.

### Django REST Framework
- Use serializers for input validation AND output formatting.
- Use ViewSets and routers for RESTful APIs.
- Use permissions classes, not manual checks in views.
- Paginate all list endpoints.

## QuerySets & Database

- Use `select_related()` for ForeignKey/OneToOne (JOIN). Use `prefetch_related()` for ManyToMany/reverse FK.
- Never query inside loops. Prefetch or annotate.
- Use `F()` expressions for database-level operations. Don't fetch, modify, and save when the DB can do it.
- Use `Q()` objects for complex filters.
- Use `.only()` or `.defer()` to limit fields on large queries. Use `.values()` or `.values_list()` when you don't need model instances.

```python
# BAD — N+1
for order in Order.objects.all():
    print(order.user.name)  # query per order

# GOOD
for order in Order.objects.select_related('user'):
    print(order.user.name)
```

## Forms & Validation

- Use Django forms or DRF serializers for input validation. Never validate manually in views.
- Use `ModelForm` when the form maps directly to a model.
- Custom validators go in `validators.py`. Reuse across forms and serializers.
- Always call `form.is_valid()` or `serializer.is_valid(raise_exception=True)` before using data.

## Migrations

- Generate migrations with `makemigrations` after every model change. Never modify the database manually.
- Review generated migrations before committing. Django sometimes generates suboptimal operations.
- Data migrations go in separate migration files from schema migrations.
- Migrations must be backwards-compatible in production (no column drops without a deprecation period).

## Background Tasks

- Use Celery or Django-Q for async operations: emails, report generation, external API calls.
- Tasks must be idempotent. Use `@shared_task` with `acks_late=True` and `reject_on_worker_lost=True`.
- Set `max_retries` and `default_retry_delay` on every task.
- Use `send_mail()` with a queue backend, or `EmailMessage.send()` inside a Celery task. Never send email synchronously in views.

## Testing

- Use `pytest-django` with `@pytest.mark.django_db` for database tests.
- Use factory_boy for test data, not fixtures.
- Test views through the test client: `self.client.get('/orders/')`.
- Test services/models directly for business logic.
- Use `override_settings` for environment-specific test config.

## Settings

- Use `django-environ` or `environs` to load settings from environment variables.
- Split settings: `base.py` (shared), `development.py`, `production.py`, `test.py`.
- Never hardcode secrets in settings files. Use environment variables.
- `DEBUG = False` in production. Always.
