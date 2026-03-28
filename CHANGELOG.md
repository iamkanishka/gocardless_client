# Changelog

All notable changes to `gocardless_client` are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] — 2026-03-27

### Initial production release

#### Core Architecture
- `GoCardlessClient.Client` — functional client struct built with `new/1` / `new!/1`
- `GoCardlessClient.Config` — NimbleOptions-validated configuration schema with `new/1` / `new!/1`
- `GoCardlessClient.Application` — OTP application, starts Finch pools and ETS rate-limit table
- `GoCardlessClient.HTTP.Client` — Finch-based HTTP client with exponential backoff + full jitter, `Retry-After` support, Telemetry events
- `GoCardlessClient.HTTP.RateLimiter` — concurrent ETS-backed `X-RateLimit-*` header tracking
- `GoCardlessClient.Paginator` — lazy `Stream`-based cursor pagination with `stream/5` and `collect/5`
- `GoCardlessClient.Resource` — shared `get/list/post/put/delete/action` helpers for all resource modules

#### Resource Modules (44 total)
All GoCardlessClient API endpoints are implemented:

**Billing Requests**
- `GoCardlessClient.Resources.BankAuthorisations` — create, get
- `GoCardlessClient.Resources.BillingRequests` — create, get, list, stream, collect_all, collect_customer_details, collect_bank_account, confirm_payer_details, fulfil, cancel, notify, fallback, change_currency, select_institution
- `GoCardlessClient.Resources.BillingRequestFlows` — create, initialise
- `GoCardlessClient.Resources.BillingRequestTemplates` — create, get, list, update
- `GoCardlessClient.Resources.Institutions` — list, list_for_billing_request

**Core Endpoints**
- `GoCardlessClient.Resources.Balances` — list
- `GoCardlessClient.Resources.BankAccountDetails` — get (encrypted)
- `GoCardlessClient.Resources.BankAccountHolderVerifications` — create, get (CoP)
- `GoCardlessClient.Resources.BankDetailsLookups` — lookup
- `GoCardlessClient.Resources.Blocks` — create, get, list, disable, enable, create_by_reference
- `GoCardlessClient.Resources.Creditors` — create, get, update, list, stream
- `GoCardlessClient.Resources.CreditorBankAccounts` — create, get, disable, list
- `GoCardlessClient.Resources.CurrencyExchangeRates` — list, stream, collect_all
- `GoCardlessClient.Resources.CustomerBankAccounts` — create, get, update, disable, list, stream, collect_all
- `GoCardlessClient.Resources.CustomerNotifications` — handle
- `GoCardlessClient.Resources.Customers` — create, get, update, remove, list, stream, collect_all
- `GoCardlessClient.Resources.Events` — get, list, stream, collect_all
- `GoCardlessClient.Resources.Exports` — get, list
- `GoCardlessClient.Resources.FundsAvailabilities` — get
- `GoCardlessClient.Resources.InstalmentSchedules` — create_with_dates, create_with_schedule, get, update, cancel, list, stream
- `GoCardlessClient.Resources.Logos` — create_for_creditor
- `GoCardlessClient.Resources.Mandates` — create, get, update, cancel, reinstate, list, stream, collect_all
- `GoCardlessClient.Resources.MandateImports` — create, get, submit, cancel
- `GoCardlessClient.Resources.MandateImportEntries` — create, list
- `GoCardlessClient.Resources.MandatePDFs` — create
- `GoCardlessClient.Resources.NegativeBalanceLimits` — list, create, delete
- `GoCardlessClient.Resources.OutboundPayments` — create, create_withdrawal, cancel, approve, get, update, list, stream, collect_all
- `GoCardlessClient.Resources.PayerAuthorisations` — create, get, update, submit, confirm
- `GoCardlessClient.Resources.PayerThemes` — create_for_creditor
- `GoCardlessClient.Resources.PaymentAccounts` — get, list
- `GoCardlessClient.Resources.PaymentAccountTransactions` — get, list, stream, collect_all
- `GoCardlessClient.Resources.Payments` — create, get, update, cancel, retry, list, stream, collect_all
- `GoCardlessClient.Resources.Payouts` — get, update, list, stream, collect_all
- `GoCardlessClient.Resources.PayoutItems` — list, stream, collect_all
- `GoCardlessClient.Resources.RedirectFlows` — create, get, complete
- `GoCardlessClient.Resources.RefundEligibilityIndicators` — get
- `GoCardlessClient.Resources.Refunds` — create, get, update, list, stream, collect_all
- `GoCardlessClient.Resources.ScenarioSimulators` — run
- `GoCardlessClient.Resources.SchemeIdentifiers` — create, get, list
- `GoCardlessClient.Resources.Subscriptions` — create, get, update, pause, resume, cancel, list, stream, collect_all
- `GoCardlessClient.Resources.TaxRates` — get, list
- `GoCardlessClient.Resources.TransferredMandates` — get
- `GoCardlessClient.Resources.Transfers` — create, get, list
- `GoCardlessClient.Resources.VerificationDetails` — create, list
- `GoCardlessClient.Resources.Webhooks` (resource) — get, list, retry, stream, collect_all

#### Webhooks
- `GoCardlessClient.Webhooks` — HMAC-SHA256 signature verification (constant-time, no `plug` dependency), event parsing, IP allowlist, event-type predicates, idempotency key generation
- `GoCardlessClient.Webhooks.Plug` — Phoenix/Plug middleware with `read_body/2` custom body reader, stores events in `conn.private[:gocardless_events]`

#### OAuth2
- `GoCardlessClient.OAuth` — `authorise_url/2`, `exchange_code/2`, `lookup_token/2`, `disconnect/2`

#### Request Signing
- `GoCardlessClient.Signing` — ECDSA P-256 / RSA request signing for Outbound Payments; produces `Date`, `Nonce`, `Digest`, `Signature` headers

#### Error Handling
- `GoCardlessClient.APIError` — structured API error with `status`, `type`, `message`, `request_id`, `errors` fields; implements `Exception`; predicate helpers: `not_found?`, `conflict?`, `validation_failed?`, `rate_limited?`, `invalid_state?`, `server_error?`
- `GoCardlessClient.FieldError` — field-level validation error from `GoCardlessClient.APIError.errors`
- `GoCardlessClient.Error` — network/SDK error with typed `reason`; `timeout/0`, `circuit_open/0`, `budget_exhausted/0`, `network/1` constructors

#### Observability
- Telemetry events: `[:gocardless, :request, :start]`, `[:gocardless, :request, :stop]`, `[:gocardless, :request, :exception]`
- ETS-backed rate-limit state via `GoCardlessClient.Client.rate_limit_state/1`

#### Testing
- `GoCardlessClient.Factory` — test fixture factory for all resource types
- `GoCardlessClient.TestCase` — ExUnit case template with Bypass integration
- 8 test modules covering: Config, Client, Error, APIError, FieldError, Webhooks, Paginator, Resources

#### Quality
- Credo strict configuration (`.credo.exs`)
- Dialyzer PLT configuration in `mix.exs`
- GitHub Actions CI: test matrix across Elixir 1.15/1.16/1.17 + OTP 25/26/27, Credo, format check, coverage, Dialyzer
- `.formatter.exs` with 100-character line length

---

## [Unreleased]

No unreleased changes.

[1.0.0]: https://github.com/iamkanishka/gocardless_client/releases/tag/v1.0.0
