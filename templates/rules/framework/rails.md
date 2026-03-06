---
paths: "**/*.rb"
version: "1.0.0"
---
<!-- keel:generated -->

# Ruby on Rails

Rules for building Rails applications.

## Architecture

- Follow Rails conventions. Don't fight the framework.
- Models: business logic and validations. Keep them focused — extract service objects when models exceed 200 lines.
- Controllers: thin. Validate params, call model/service, render response.
- For complex domains: `app/services/` for service objects, `app/queries/` for complex queries, `app/presenters/` for view logic.

## Models & ActiveRecord

- Define validations in models. Don't validate in controllers.
- Use scopes for reusable queries: `scope :active, -> { where(active: true) }`.
- Eager load associations to avoid N+1: `includes(:orders)`, `preload(:items)`.
- Use `strong_parameters` in controllers. Never use `permit!`.
- Add database indexes for columns used in WHERE, ORDER BY, and foreign keys.

```ruby
# BAD
User.all.each { |u| puts u.orders.count } # N+1

# GOOD
User.includes(:orders).each { |u| puts u.orders.count }
```

## Controllers

- Use `before_action` for shared logic (authentication, loading resources).
- Stick to RESTful actions: `index`, `show`, `new`, `create`, `edit`, `update`, `destroy`.
- If a controller needs non-REST actions, consider extracting a new resource.
- Use `respond_to` for format handling in controllers that serve multiple formats.

## Service Objects

Use service objects for operations that:
- Involve multiple models
- Interact with external services
- Have complex business logic
- Don't fit naturally in a single model

```ruby
# app/services/place_order.rb
class PlaceOrder
  def initialize(user:, cart:, payment_method:)
    @user = user
    @cart = cart
    @payment_method = payment_method
  end

  def call
    order = Order.create!(user: @user, items: @cart.items)
    ProcessPayment.new(order: order, method: @payment_method).call
    OrderMailer.confirmation(order).deliver_later
    order
  end
end
```

## Database & Migrations

- Always use migrations for schema changes. Never modify the database manually.
- Migrations must be reversible. Define both `up` and `down`, or use `change` with reversible methods.
- Add indexes in migrations, not after the fact.
- Use `null: false` and default values where appropriate.
- Use foreign key constraints: `add_foreign_key`.

## Background Jobs

- Use ActiveJob (backed by Sidekiq, GoodJob, etc.) for anything that doesn't need to complete during the request.
- Jobs must be idempotent. Running the same job twice produces the same result.
- Set `retry_on` and `discard_on` for error handling. Don't let jobs fail silently.
- Use `deliver_later` for all emails.

## Testing

- Use RSpec or Minitest — follow the project's existing choice.
- Use FactoryBot for test data, not fixtures (unless the project already uses fixtures).
- Test models: validations, scopes, business logic.
- Test controllers: through request specs, not controller specs.
- Test services: directly with unit tests.
- Use `database_cleaner` or transactional tests for database isolation.

## Security

- Use `params.require(:order).permit(:item_id, :quantity)` — never `params.permit!`.
- Use `has_secure_password` for password handling. Never store plaintext passwords.
- Escape output in views (Rails does this by default — don't use `raw` or `html_safe` without reason).
- Use CSRF protection (enabled by default). Don't skip it.

## Configuration

- Use `credentials.yml.enc` for secrets. Never commit unencrypted secrets.
- Use environment variables for environment-specific configuration.
- Use `config_for` to load custom YAML config files.
