defmodule GoCardlessClient do
  @moduledoc """
  Production-ready Elixir client for the [GoCardlessClient API](https://developer.gocardless.com/api-reference/).

  ## Quick Start

      # 1. Configure in config/config.exs
      config :gocardless_client,
        access_token: System.get_env("GOCARDLESS_ACCESS_TOKEN"),
        environment: :sandbox   # or :live

      # 2. Build a client
      client = GoCardlessClient.client!()

      # 3. Call the API
      {:ok, customer} = GoCardlessClient.Resources.Customers.create(client, %{
        email: "alice@example.com",
        given_name: "Alice",
        family_name: "Smith",
        country_code: "GB"
      })

      {:ok, mandate} = GoCardlessClient.Resources.Mandates.create(client, %{
        scheme: "bacs",
        links: %{customer_bank_account: bank_account_id}
      })

      {:ok, payment} = GoCardlessClient.Resources.Payments.create(client, %{
        amount: 1500,
        currency: "GBP",
        description: "Monthly fee",
        links: %{mandate: mandate_id}
      })

  ## Runtime Clients

      client = GoCardlessClient.client!(access_token: "tok", environment: :live)

      # Per-merchant token (OAuth partner apps)
      client = GoCardlessClient.client!(access_token: merchant_token)

  ## Pagination

      # Stream lazily — no memory pressure on large datasets
      GoCardlessClient.Resources.Payments.stream(client, %{status: "paid_out"})
      |> Stream.each(&reconcile/1)
      |> Stream.run()

      # Or collect all pages eagerly
      {:ok, all_customers} = GoCardlessClient.Resources.Customers.collect_all(client)

  ## Webhooks

      # In your Phoenix controller:
      def handle(conn, _params) do
        events = conn.private[:gocardless_events]
        Enum.each(events, &dispatch_event/1)
        send_resp(conn, 200, "")
      end

  ## Modules

  | Module | Description |
  |--------|-------------|
  | `GoCardlessClient.Client` | Client struct and builder |
  | `GoCardlessClient.Config` | Configuration with NimbleOptions validation |
  | `GoCardlessClient.Resources.Customers` | Customer management |
  | `GoCardlessClient.Resources.CustomerBankAccounts` | Customer bank accounts |
  | `GoCardlessClient.Resources.Mandates` | Direct Debit mandate lifecycle |
  | `GoCardlessClient.Resources.Payments` | Payment creation and management |
  | `GoCardlessClient.Resources.Subscriptions` | Recurring payment schedules |
  | `GoCardlessClient.Resources.InstalmentSchedules` | Fixed instalment plans |
  | `GoCardlessClient.Resources.BillingRequests` | Open Banking / Pay by Bank |
  | `GoCardlessClient.Resources.BillingRequestFlows` | Hosted billing request UI |
  | `GoCardlessClient.Resources.BankAuthorisations` | Bank authorisation management |
  | `GoCardlessClient.Resources.RedirectFlows` | GoCardlessClient-hosted mandate setup |
  | `GoCardlessClient.Resources.Payouts` | Payout management |
  | `GoCardlessClient.Resources.PayoutItems` | Payout reconciliation |
  | `GoCardlessClient.Resources.Refunds` | Payment refunds |
  | `GoCardlessClient.Resources.Events` | Event log |
  | `GoCardlessClient.Resources.Creditors` | Creditor management |
  | `GoCardlessClient.Resources.OutboundPayments` | Send money (requires signing) |
  | `GoCardlessClient.Resources.ScenarioSimulators` | Sandbox test triggers |
  | `GoCardlessClient.Webhooks` | Signature verification and event parsing |
  | `GoCardlessClient.Webhooks.Plug` | Phoenix/Plug middleware |
  | `GoCardlessClient.OAuth` | OAuth2 partner flow |
  | `GoCardlessClient.Signing` | ECDSA request signing |
  | `GoCardlessClient.Paginator` | Cursor-based pagination streams |
  | `GoCardlessClient.APIError` | Structured API error |
  | `GoCardlessClient.Error` | Network/SDK error |

  ## Using Resource Modules

  All resource operations live in `GoCardlessClient.Resources.*`. Use module aliases
  for ergonomic access:

      alias GoCardlessClient.Resources.{Customers, Payments, Mandates, Subscriptions}

      {:ok, customer} = Customers.create(client, %{email: "alice@example.com"})
      {:ok, payment}  = Payments.create(client, %{amount: 1500, currency: "GBP"})
  """

  alias GoCardlessClient.{Client, Config}

  # ── Client builders ────────────────────────────────────────────────────

  @doc """
  Builds a `GoCardlessClient.Client` from application config merged with `opts`.

  Returns `{:ok, client}` or `{:error, %NimbleOptions.ValidationError{}}`.
  """
  @spec client(keyword()) :: {:ok, Client.t()} | {:error, NimbleOptions.ValidationError.t()}
  def client(opts \\ []), do: Client.new(opts)

  @doc "Like `client/1` but raises `ArgumentError` on invalid options."
  @spec client!(keyword()) :: Client.t()
  def client!(opts \\ []), do: Client.new!(opts)

  @doc "Returns a new idempotency key (32 random hex chars)."
  @spec new_idempotency_key() :: String.t()
  def new_idempotency_key do
    :crypto.strong_rand_bytes(16) |> Base.encode16(case: :lower)
  end

  @doc "Returns the current rate-limit state from the last observed API response."
  @spec rate_limit_state(Client.t()) :: map()
  def rate_limit_state(%Client{} = client), do: Client.rate_limit_state(client)

  @doc "Returns the resolved base URL for a client's environment."
  @spec base_url(Client.t()) :: String.t()
  def base_url(%Client{config: config}), do: Config.base_url(config)
end
