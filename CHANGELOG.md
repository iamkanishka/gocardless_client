# Changelog

All notable changes to this project will be documented in this file.

## [2.0.0] — 2026-05-24

### 🔴 Breaking bug fixes

- **`Resource.update/5` now uses HTTP POST** (was incorrectly using HTTP PUT).
  GoCardless does not support PUT — all update operations require POST to the
  resource endpoint. This was a silent runtime failure: all `update/4` calls
  across every resource were returning `405 Method Not Allowed` from the API.

- **Action endpoints now wrap params in the resource key** (was wrapping in `"data"`).
  The GoCardless API requires `%{"billing_requests" => params}`, not
  `%{"data" => params}`. Every `cancel`, `retry`, `fulfil`, `pause`, `resume`,
  `approve`, and other action calls were failing with validation errors.

- **Fixed `GoCardless-Version` header name** (was `GoCardlessClient-Version`).
  The API was silently receiving no valid version header on every request.

### 🆕 New modules

- `GoCardlessClient.Resources.BillingRequestWithActions` — single-call API
  combining billing request creation + actions (`POST /billing_requests_with_actions`)
- `GoCardlessClient.Resources.OutboundPaymentImports` — bulk outbound payment
  import batches (`POST /outbound_payment_imports`, `GET`, list)
- `GoCardlessClient.Resources.OutboundPaymentImportEntries` — entries within an
  outbound payment import batch

### 🆕 New functions on existing modules

- `OutboundPayments.withdrawal/3` — `POST /outbound_payments/withdrawal`
- `OutboundPayments.statistics/2` — `GET /outbound_payments/statistics`
- `Blocks.block_by_reference/3` — `POST /blocks/block_by_reference`
- `Institutions.list_for_billing_request/4` — `GET /billing_requests/:id/institutions`
- `ScenarioSimulators.run/4` — `POST /scenario_simulators/:type/actions/run`
  (previously referenced in docs but never defined — caused `UndefinedFunctionError`)
- `RedirectFlows.list/3` and `stream/3`
- `InstalmentSchedules.create_with_dates/3` and `create_with_schedule/3`
  (replaces ambiguous `create/3` with clearly named wrappers)

### 🆕 New webhook event type helpers

Added to `GoCardlessClient.Webhooks`:
- `instalment_schedule_event?/1`
- `outbound_payment_event?/1`
- `creditor_event?/1`
- `customer_event?/1`
- `export_event?/1`
- `payment_account_transaction_event?/1`
- `scheme_identifier_event?/1`

### 🗑️ Removed

- `GoCardlessClient.Resources.Transfers` — this module referenced a
  `/transfers` endpoint that does not exist in the GoCardless API. All calls
  would have returned `404`. Removed entirely.

### 🧹 Phantom function cleanup

Removed `create/3` and `update/4` from read-only resources where these
operations don't exist in the API:

- `Balances` — read-only; removed phantom `create/3`, `update/4`
- `CurrencyExchangeRates` — read-only; removed phantom `create/3`, `update/4`
- `Events` — read-only; removed phantom `create/3`, `update/4`
- `Exports` — read-only; removed phantom `create/3`, `update/4`
- `NegativeBalanceLimits` — read-only; removed phantom `create/3`, `update/4`
- `PayoutItems` — list-only; removed phantom `create/3`, `get/3`, `update/4`
- `PaymentAccounts` — read-only; removed phantom `create/3`, `update/4`
- `PaymentAccountTransactions` — read-only; removed phantom `create/3`, `update/4`
- `Payouts` — read-only except metadata; removed phantom `create/3`
- `TaxRates` — read-only; removed phantom `create/3`, `update/4`
- `TransferredMandates` — get-only; removed phantom `create/3`, `list/3`, `update/4`
- `Institutions` — removed phantom `create/3`, `update/4`
- `Logos` — write-only; removed phantom `get/3`, `list/3`, `update/4`
- `MandatePDFs` — write-only; removed phantom `get/3`, `list/3`
- `FundsAvailabilities` — renamed `create/3` → `check/3`; removed phantom `get/3`, `list/3`
- `CustomerNotifications` — removed phantom `create/3`, `get/3`, `list/3`, `update/4`; kept `handle/4`
- `BankDetailsLookups` — renamed `create/3` → `lookup/3`; removed phantom `get/3`, `list/3`
- `BankAccountDetails` — removed phantom `create/3`, `update/4`; kept `get/3`
- `MandateImports` — removed phantom `list/3` (the API has no list endpoint for this resource)

### 🧪 Tests

- **Fixed `GoCardlessClient.TestCase`** — Bypass server URL was opened but
  never wired to the client; every HTTP test was silently hitting the real
  GoCardless sandbox (or failing with connection errors). The client now
  receives a `_base_url_override` pointing at the local Bypass server.

- Added Bypass-wired tests for **15 resource modules** (from 2):
  - `CustomersTest` — create, get, list, update (POST not PUT), remove (DELETE), header assertions
  - `PaymentsTest` — create, cancel (action key), retry, list, update (POST not PUT)
  - `MandatesTest` — create, cancel (action key), reinstate
  - `BillingRequestsTest` — create, all action endpoints (verifies resource key wrapping)
  - `SubscriptionsTest` — create, pause, resume, cancel
  - `ScenarioSimulatorsTest` — run/4 path, mandate scenario, invalid scenario guard
  - `BlocksTest` — create, block_by_reference, disable/enable actions
  - `OutboundPaymentsTest` — create, withdrawal, statistics, cancel, approve
  - `InstalmentSchedulesTest` — create_with_dates, create_with_schedule, cancel
  - `BillingRequestWithActionsTest` — full single-call flow
  - `RedirectFlowsTest` — create, complete, list
  - `PayoutsTest` — list, update (POST), PayoutItems.list
  - `WebhooksResourceTest` — list, retry
  - `EventsTest` — list with filters, get
  - `MiscResourcesTest` — BankDetailsLookups, FundsAvailabilities, MandatePDFs, Institutions, Balances, CustomerNotifications
  - `PaginatorTest` — single-page, multi-page cursor following, error propagation
  - `WebhooksHelpersTest` — all 7 new event type helpers, payload size guard

### Upgrade guide

**Update all `create/3` calls for renamed functions:**

```elixir
# Before (returns 404)
GoCardlessClient.Resources.FundsAvailabilities.create(client, params)
GoCardlessClient.Resources.BankDetailsLookups.create(client, params)

# After
GoCardlessClient.Resources.FundsAvailabilities.check(client, params)
GoCardlessClient.Resources.BankDetailsLookups.lookup(client, params)
```

**Replace ambiguous `InstalmentSchedules.create/3`:**

```elixir
# Before
GoCardlessClient.Resources.InstalmentSchedules.create(client, %{instalments: [...]})

# After (explicit)
GoCardlessClient.Resources.InstalmentSchedules.create_with_dates(client, %{instalments: [...]})
GoCardlessClient.Resources.InstalmentSchedules.create_with_schedule(client, %{interval_unit: "monthly", ...})
```

**Remove any direct `Transfers` module usage:**

```elixir
# Before (returns 404 — endpoint doesn't exist)
GoCardlessClient.Resources.Transfers.create(client, params)

# Use TransferredMandates for post-switch mandate data:
GoCardlessClient.Resources.TransferredMandates.get(client, mandate_id)
```

## [1.0.0] — Initial release
