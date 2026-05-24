# GoCardlessClient

[![Hex.pm](https://img.shields.io/hexpm/v/gocardless_client.svg)](https://hex.pm/packages/gocardless_client)
[![Documentation](https://img.shields.io/badge/hex-docs-blue.svg)](https://hexdocs.pm/gocardless_client)
[![CI](https://github.com/iamkanishka/gocardless_client/actions/workflows/ci.yml/badge.svg)](https://github.com/iamkanishka/gocardless_client/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Production-ready Elixir client for the [GoCardless API](https://developer.gocardless.com/api-reference/). Complete coverage of all 139 endpoints across 46 resource modules — payments, mandates, billing requests, subscriptions, outbound payments, webhooks, OAuth2, and more.

---

## Features

| Capability                | Detail                                                                         |
| ------------------------- | ------------------------------------------------------------------------------ |
| **Complete API coverage** | All 139 GoCardless API endpoints across 46 resource modules                    |
| **Billing Requests**      | Full Open Banking flow — mandate setup, instant payments, fallback to DD       |
| **Outbound Payments**     | Send money with ECDSA P-256 / RSA request signing                              |
| **OAuth2**                | Partner platform auth URL, token exchange, lookup, disconnect                  |
| **Resilience**            | Exponential backoff + full jitter, honours `Retry-After` header                |
| **Pagination**            | Lazy `Stream` and eager `collect_all` — zero memory pressure on large datasets |
| **Webhooks**              | HMAC-SHA256 constant-time verification, Phoenix Plug middleware, IP allowlist  |
| **Telemetry**             | `[:gocardless, :request, :start/stop/exception]` events                        |
| **Rate limits**           | `X-RateLimit-*` header tracking, accessible at runtime                         |
| **Config**                | NimbleOptions-validated schema — catches misconfiguration at startup           |
| **OTP**                   | Finch connection pools, supervised under `GoCardlessClient.Supervisor`         |

---

## Installation

```elixir
# mix.exs
def deps do
  [{:gocardless_client, "~> 2.0"}]
end
```

---

## Configuration

```elixir
# config/config.exs
config :gocardless_client,
  access_token: System.get_env("GOCARDLESS_ACCESS_TOKEN"),
  environment: :sandbox,  # or :live
  timeout: 30_000,
  max_retries: 3
```

### Runtime client

```elixir
# Build a client at runtime (overrides application config)
client = GoCardlessClient.client!(access_token: token, environment: :live)
```

---

## Quick Start

```elixir
alias GoCardlessClient.Resources.{
  CustomerBankAccounts,
  Customers,
  Mandates,
  Payments
}

client = GoCardlessClient.client!()

# 1. Create a customer
{:ok, customer} = Customers.create(client, %{
  email: "alice@example.com",
  given_name: "Alice",
  family_name: "Smith",
  country_code: "GB"
})

# 2. Add their bank account
{:ok, bank_account} = CustomerBankAccounts.create(client, %{
  account_holder_name: "Alice Smith",
  account_number: "55779911",
  branch_code: "200000",
  country_code: "GB",
  links: %{customer: customer["id"]}
})

# 3. Create a mandate
{:ok, mandate} = Mandates.create(client, %{
  scheme: "bacs",
  links: %{customer_bank_account: bank_account["id"]}
})

# 4. Charge the customer
{:ok, payment} = Payments.create(client, %{
  amount: 1500,
  currency: "GBP",
  description: "Monthly subscription",
  links: %{mandate: mandate["id"]}
}, idempotency_key: GoCardlessClient.new_idempotency_key())
```

---

## Billing Requests (Open Banking / Pay by Bank)

The modern flow for collecting both mandates and instant bank payments, with built-in Open Banking support and fallback to Direct Debit.

### Hosted flow (simplest)

```elixir
alias GoCardlessClient.Resources.{BillingRequestFlows, BillingRequests}

# Mandate + optional instant payment in one flow
{:ok, br} = BillingRequests.create(client, %{
  mandate_request: %{currency: "GBP", scheme: "bacs"},
  payment_request: %{amount: 5000, currency: "GBP", description: "Setup fee"}
})

{:ok, flow} = BillingRequestFlows.create(client, %{
  redirect_uri: "https://myapp.com/complete",
  exit_uri: "https://myapp.com/cancel",
  links: %{billing_request: br["id"]}
})

# Redirect customer to flow["authorisation_url"]
```

### Server-side flow (single call)

```elixir
alias GoCardlessClient.Resources.BillingRequestWithActions

{:ok, result} = BillingRequestWithActions.create(client, %{
  mandate_request: %{currency: "GBP"},
  actions: [
    %{
      type: "collect_customer_details",
      collect_customer_details: %{
        customer: %{given_name: "Alice", family_name: "Smith", email: "alice@example.com"},
        customer_billing_detail: %{address_line1: "1 Example St", city: "London",
                                   postal_code: "EC1A 1BB", country_code: "GB"}
      }
    },
    %{
      type: "collect_bank_account",
      collect_bank_account: %{
        account_holder_name: "Alice Smith",
        account_number: "55779911",
        branch_code: "200000",
        country_code: "GB"
      }
    },
    %{type: "confirm_payer_details", confirm_payer_details: %{}},
    %{type: "fulfil", fulfil: %{}}
  ]
})
```

---

## Subscriptions

```elixir
alias GoCardlessClient.Resources.Subscriptions

{:ok, sub} = Subscriptions.create(client, %{
  amount: 2500,
  currency: "GBP",
  name: "Premium Monthly",
  interval_unit: "monthly",
  interval: 1,
  day_of_month: 1,
  links: %{mandate: mandate_id}
})

{:ok, _} = Subscriptions.pause(client, sub["id"], %{pause_cycles: 2})
{:ok, _} = Subscriptions.resume(client, sub["id"])
{:ok, _} = Subscriptions.cancel(client, sub["id"])
```

---

## Instalment Schedules

```elixir
alias GoCardlessClient.Resources.InstalmentSchedules

# Explicit dates
{:ok, schedule} = InstalmentSchedules.create_with_dates(client, %{
  name: "3-month plan",
  currency: "GBP",
  instalments: [
    %{charge_date: "2025-02-01", amount: 5000},
    %{charge_date: "2025-03-01", amount: 5000},
    %{charge_date: "2025-04-01", amount: 5000}
  ],
  links: %{mandate: mandate_id}
})

# Interval-based
{:ok, schedule} = InstalmentSchedules.create_with_schedule(client, %{
  name: "6-month plan",
  currency: "GBP",
  amount: 3000,
  start_date: "2025-02-01",
  count: 6,
  interval_unit: "monthly",
  interval: 1,
  links: %{mandate: mandate_id}
})
```

---

## Outbound Payments

Requires an ECDSA P-256 private key registered in your GoCardless dashboard.

```elixir
alias GoCardlessClient.Resources.OutboundPayments
alias GoCardlessClient.Signing

signer = Signing.new!(
  key_id: System.get_env("GC_SIGNING_KEY_ID"),
  pem: File.read!("private_key.pem"),
  algorithm: :ecdsa
)

# Send to a recipient
{:ok, payment} = OutboundPayments.create(client, %{
  amount: 50_000,
  currency: "GBP",
  description: "Supplier invoice #1234",
  links: %{payment_account: "PA123", creditor: "CR456"},
  recipient_bank_account: %{
    account_holder_name: "Acme Ltd",
    account_number: "12345678",
    branch_code: "204514",
    country_code: "GB"
  }
}, signer: signer, idempotency_key: GoCardlessClient.new_idempotency_key())

# Withdraw funds to your own bank account
{:ok, _} = OutboundPayments.withdrawal(client, %{
  amount: 100_000,
  currency: "GBP",
  links: %{payment_account: "PA123", creditor_bank_account: "BA456"}
}, signer: signer, idempotency_key: GoCardlessClient.new_idempotency_key())

# Check available funds first
{:ok, avail} = GoCardlessClient.Resources.FundsAvailabilities.check(client, %{
  amount: 50_000, currency: "GBP"
})
```

---

## Pagination

All list endpoints support lazy streaming and eager collection:

```elixir
alias GoCardlessClient.Resources.Payments

# Lazy stream — fetches pages on demand, no memory pressure
Payments.stream(client, %{status: "paid_out"})
|> Stream.filter(&(&1["amount"] > 1000))
|> Stream.each(&reconcile/1)
|> Stream.run()

# Collect all pages eagerly
{:ok, all_payments} = Payments.collect_all(client, %{mandate: mandate_id})

# Single page with cursor
{:ok, %{items: payments, meta: meta}} = Payments.list(client, %{limit: 50, after: cursor})
next_cursor = get_in(meta, ["cursors", "after"])
```

---

## Error Handling

```elixir
case GoCardlessClient.Resources.Payments.create(client, params) do
  {:ok, payment} ->
    process(payment)

  {:error, %GoCardlessClient.APIError{} = err} ->
    cond do
      GoCardlessClient.APIError.validation_failed?(err) ->
        Enum.each(err.errors, &Logger.error("#{&1.field}: #{&1.message}"))

      GoCardlessClient.APIError.rate_limited?(err) ->
        Logger.warning("Rate limited — request_id: #{err.request_id}")

      GoCardlessClient.APIError.invalid_state?(err) ->
        Logger.warning("Invalid state: #{err.message}")

      GoCardlessClient.APIError.not_found?(err) ->
        Logger.warning("Not found")

      GoCardlessClient.APIError.server_error?(err) ->
        Logger.error("GoCardless internal error — request_id: #{err.request_id}")
    end

  {:error, %GoCardlessClient.Error{reason: :timeout}} ->
    Logger.error("Request timed out")
end
```

---

## Webhooks

### Phoenix Plug (recommended)

Add to `endpoint.ex` **before** `Plug.Parsers`:

```elixir
plug Plug.Parsers,
  parsers: [:json],
  json_decoder: Jason,
  body_reader: {GoCardlessClient.Webhooks.Plug, :read_body, []}
```

Add to `router.ex`:

```elixir
pipeline :gocardless_webhooks do
  plug GoCardlessClient.Webhooks.Plug,
    secret: System.get_env("GOCARDLESS_WEBHOOK_SECRET")
end

scope "/webhooks" do
  pipe_through :gocardless_webhooks
  post "/gocardless", MyApp.WebhookController, :handle
end
```

In your controller:

```elixir
def handle(conn, _params) do
  conn.private[:gocardless_events]
  |> Enum.each(&dispatch/1)

  send_resp(conn, 200, "")
end

defp dispatch(%{"resource_type" => "payments", "action" => "paid_out"} = event),
  do: Reconciler.payment_paid_out(event)

defp dispatch(%{"resource_type" => "mandates", "action" => "active"} = event),
  do: MandateHandler.activated(event)

defp dispatch(%{"resource_type" => "billing_requests", "action" => "fulfilled"} = event),
  do: OnboardingFlow.complete(event)

defp dispatch(_event), do: :ok
```

### Manual verification

```elixir
secret = System.get_env("GOCARDLESS_WEBHOOK_SECRET")

case GoCardlessClient.Webhooks.parse(raw_body, signature_header, secret) do
  {:ok, events} -> Enum.each(events, &dispatch/1)
  {:error, :invalid_signature} -> Logger.warning("Forged webhook rejected")
  {:error, :payload_too_large}  -> Logger.warning("Oversized payload rejected")
  {:error, :invalid_json}       -> Logger.warning("Malformed payload")
end
```

### Event type helpers

```elixir
alias GoCardlessClient.Webhooks

Webhooks.payment_event?(event)                    # resource_type == "payments"
Webhooks.mandate_event?(event)                    # resource_type == "mandates"
Webhooks.subscription_event?(event)               # resource_type == "subscriptions"
Webhooks.billing_request_event?(event)            # resource_type == "billing_requests"
Webhooks.payout_event?(event)                     # resource_type == "payouts"
Webhooks.refund_event?(event)                     # resource_type == "refunds"
Webhooks.outbound_payment_event?(event)           # resource_type == "outbound_payments"
Webhooks.instalment_schedule_event?(event)        # resource_type == "instalment_schedules"
Webhooks.creditor_event?(event)                   # resource_type == "creditors"
Webhooks.customer_event?(event)                   # resource_type == "customers"
Webhooks.export_event?(event)                     # resource_type == "exports"
Webhooks.scheme_identifier_event?(event)          # resource_type == "scheme_identifiers"
Webhooks.payment_account_transaction_event?(event)# resource_type == "payment_account_transactions"
Webhooks.action?(event, "paid_out")               # action == "paid_out"
```

---

## OAuth2 (Partner Platforms)

```elixir
alias GoCardlessClient.OAuth

config = %{
  client_id: System.get_env("GC_CLIENT_ID"),
  client_secret: System.get_env("GC_CLIENT_SECRET"),
  redirect_uri: "https://yourapp.com/oauth/callback",
  environment: :live
}

# 1. Redirect merchant to GoCardless
auth_url = OAuth.authorise_url(config, scope: "read_write", state: csrf_token)

# 2. Exchange code for token
{:ok, token} = OAuth.exchange_code(config, params["code"])

# 3. Build a merchant-scoped client
merchant_client = GoCardlessClient.client!(
  access_token: token["access_token"],
  environment: :live
)

# Lookup organisation details
{:ok, info} = OAuth.lookup_token(config, token["access_token"])

# Revoke
:ok = OAuth.disconnect(config, token["access_token"])
```

---

## Mandate Imports (Migrations)

Bulk-import mandates from another payment provider:

```elixir
alias GoCardlessClient.Resources.{MandateImportEntries, MandateImports}

{:ok, import} = MandateImports.create(client, %{scheme: "bacs"})

{:ok, _} = MandateImportEntries.add(client, %{
  record_identifier: "CUST-001",
  amendment: %{
    original_creditor_id: "OLD-CR-001",
    original_creditor_name: "Old Provider Ltd",
    original_mandate_reference: "OLD-REF-001"
  },
  customer: %{given_name: "Alice", family_name: "Smith", email: "alice@example.com",
               address_line1: "1 Example St", city: "London",
               postal_code: "EC1A 1BB", country_code: "GB"},
  bank_account: %{account_holder_name: "Alice Smith",
                  sort_code: "200000", account_number: "55779911"},
  links: %{mandate_import: import["id"]}
})

{:ok, _} = MandateImports.submit(client, import["id"])
```

---

## Payout Reconciliation

```elixir
alias GoCardlessClient.Resources.{Events, PayoutItems, Payouts}

{:ok, %{items: payouts}} = Payouts.list(client, %{status: "paid"})

# Get line items for a specific payout
{:ok, %{items: items}} = PayoutItems.list(client, %{payout: "PO123"})

fees       = Enum.filter(items, &(&1["type"] == "gocardless_fee"))
payments   = Enum.filter(items, &(&1["type"] == "payment_paid_out"))
chargebacks = Enum.filter(items, &(&1["type"] == "payment_charged_back"))

# Get the event log for the payout
{:ok, %{items: events}} = Events.list(client, %{payout: "PO123"})
```

---

## Scenario Simulators (Sandbox Only)

Trigger payment lifecycle events without real bank interactions:

```elixir
alias GoCardlessClient.Resources.ScenarioSimulators

# Payment scenarios
{:ok, _} = ScenarioSimulators.run(client, "payment_paid_out",  %{links: %{payment: "PM123"}})
{:ok, _} = ScenarioSimulators.run(client, "payment_failed",    %{links: %{payment: "PM123"}})
{:ok, _} = ScenarioSimulators.run(client, "payment_charged_back", %{links: %{payment: "PM123"}})

# Mandate scenarios
{:ok, _} = ScenarioSimulators.run(client, "mandate_activated", %{links: %{mandate: "MD456"}})
{:ok, _} = ScenarioSimulators.run(client, "mandate_failed",    %{links: %{mandate: "MD456"}})

# Billing request scenarios
{:ok, _} = ScenarioSimulators.run(client, "billing_request_fulfilled",
  %{links: %{billing_request: "BRQ789"}})

# List all available scenario types
ScenarioSimulators.valid_scenarios()
```

---

## Telemetry

```elixir
:telemetry.attach_many("gocardless-metrics", [
  [:gocardless, :request, :start],
  [:gocardless, :request, :stop],
  [:gocardless, :request, :exception]
], &MyApp.Telemetry.handle_event/4, nil)

# Metadata on :stop event:
# %{method: :post, url: "https://api.gocardless.com/payments",
#   attempt: 1, status: 201, duration: 143}
```

---

## Rate Limit State

```elixir
state = GoCardlessClient.rate_limit_state(client)
# => %{limit: 1000, remaining: 950, reset_at: ~U[2025-01-15 10:30:00Z]}
```

---

## Complete Resource Reference

| Module                           | Endpoints | Key operations                                                     |
| -------------------------------- | --------- | ------------------------------------------------------------------ |
| `BankAuthorisations`             | 2         | create, get                                                        |
| `BillingRequests`                | 14        | create, get, list, update + 9 actions                              |
| `BillingRequestFlows`            | 2         | create, initialise                                                 |
| `BillingRequestTemplates`        | 4         | create, get, list, update                                          |
| `BillingRequestWithActions`      | 1         | create                                                             |
| `Institutions`                   | 2         | list, list_for_billing_request                                     |
| `Balances`                       | 1         | list                                                               |
| `BankAccountDetails`             | 1         | get                                                                |
| `BankAccountHolderVerifications` | 2         | create, get                                                        |
| `BankDetailsLookups`             | 1         | lookup                                                             |
| `Blocks`                         | 6         | create, get, list, disable, enable, block_by_reference             |
| `Creditors`                      | 4         | create, get, list, update                                          |
| `CreditorBankAccounts`           | 5         | create, get, list, update, disable                                 |
| `CurrencyExchangeRates`          | 1         | list                                                               |
| `Customers`                      | 5         | create, get, list, update, remove (GDPR)                           |
| `CustomerBankAccounts`           | 5         | create, get, list, update, disable                                 |
| `CustomerNotifications`          | 1         | handle                                                             |
| `Events`                         | 2         | get, list                                                          |
| `Exports`                        | 2         | get, list                                                          |
| `FundsAvailabilities`            | 1         | check                                                              |
| `InstalmentSchedules`            | 6         | create_with_dates, create_with_schedule, get, list, update, cancel |
| `Logos`                          | 1         | create                                                             |
| `Mandates`                       | 6         | create, get, list, update, cancel, reinstate                       |
| `MandateImports`                 | 4         | create, get, submit, cancel                                        |
| `MandateImportEntries`           | 2         | add, list                                                          |
| `MandatePDFs`                    | 1         | create                                                             |
| `NegativeBalanceLimits`          | 1         | list                                                               |
| `OutboundPayments`               | 8         | create, withdrawal, get, list, update, cancel, approve, statistics |
| `OutboundPaymentImports`         | 3         | create, get, list                                                  |
| `OutboundPaymentImportEntries`   | 1         | list                                                               |
| `PayerAuthorisations`            | 6         | create, get, list, update, submit, confirm                         |
| `PayerThemes`                    | 1         | create                                                             |
| `Payments`                       | 6         | create, get, list, update, cancel, retry                           |
| `PaymentAccounts`                | 2         | get, list                                                          |
| `PaymentAccountTransactions`     | 2         | get, list                                                          |
| `Payouts`                        | 3         | get, list, update                                                  |
| `PayoutItems`                    | 1         | list                                                               |
| `RedirectFlows`                  | 4         | create, get, list, complete                                        |
| `Refunds`                        | 4         | create, get, list, update                                          |
| `ScenarioSimulators`             | 1         | run (19 scenario types)                                            |
| `SchemeIdentifiers`              | 4         | create, get, list, update                                          |
| `Subscriptions`                  | 7         | create, get, list, update, pause, resume, cancel                   |
| `TaxRates`                       | 2         | get, list                                                          |
| `TransferredMandates`            | 1         | get                                                                |
| `VerificationDetails`            | 3         | create, get, list                                                  |
| `Webhooks` (resource)            | 3         | get, list, retry                                                   |

All list endpoints also expose `stream/3` (lazy `Stream`) and `collect_all/3` (eager list).

---

## Running Tests

```bash
mix deps.get
mix test
mix test --cover
mix credo --strict
mix dialyzer
```

---

## License

MIT — see [LICENSE](LICENSE).
