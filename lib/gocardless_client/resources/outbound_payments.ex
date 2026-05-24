defmodule GoCardlessClient.Resources.OutboundPayments do
  @moduledoc """
  GoCardless Outbound Payments API.

  Outbound Payments send money from your Payment Account to recipients.
  They require API request signing with an ECDSA P-256 private key registered
  in your GoCardless dashboard.

  ## Rate limiting

  Outbound Payments has stricter rate limits than other endpoints. Check the
  `GoCardlessClient.Client.rate_limit_state/1` after each call.

  ## Outbound payment states

  `created` → `pending_approval` (optional) → `executing` → `executed` / `failed` / `cancelled`

  ## Example — send a payment

      signer = GoCardlessClient.Signing.new!(key_id: "kid", pem: pem)

      {:ok, payment} = GoCardlessClient.Resources.OutboundPayments.create(client,
        %{
          amount: 50_000,
          currency: "GBP",
          description: "Supplier invoice #1234",
          recipient_bank_account: %{
            account_holder_name: "Acme Ltd",
            account_number: "12345678",
            branch_code: "204514",
            country_code: "GB"
          },
          links: %{creditor: "CR123", payment_account: "PA123"}
        },
        signer: signer,
        idempotency_key: GoCardlessClient.new_idempotency_key()
      )

  ## Example — withdraw funds to your own bank account

      {:ok, withdrawal} = GoCardlessClient.Resources.OutboundPayments.withdrawal(client,
        %{
          amount: 100_000,
          currency: "GBP",
          links: %{
            payment_account: "PA123",
            creditor_bank_account: "BA456"
          }
        },
        signer: signer,
        idempotency_key: GoCardlessClient.new_idempotency_key()
      )
  """

  alias GoCardlessClient.{Client, HTTP, Paginator, Resource}

  @resource_key "outbound_payments"
  @base_path "/outbound_payments"

  @doc """
  Creates an outbound payment to a recipient.

  Always pass an idempotency key and a `:signer` for safe retries and security.
  """
  @spec create(Client.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def create(%Client{} = client, params, opts \\ []) do
    Resource.post(client, @base_path, @resource_key, params, opts)
  end

  @doc """
  Creates a withdrawal — sends funds from the Payment Account to your own
  creditor bank account. Useful for sweeping collected funds.
  """
  @spec withdrawal(Client.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def withdrawal(%Client{} = client, params, opts \\ []) do
    Resource.post(client, "#{@base_path}/withdrawal", @resource_key, params, opts)
  end

  @doc "Retrieves a single outbound payment by ID."
  @spec get(Client.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def get(%Client{} = client, id, opts \\ []) do
    Resource.get(client, "#{@base_path}/#{id}", @resource_key, opts)
  end

  @doc "Returns a page of outbound payments. Filter by `:status`, `:currency`, `:payment_account`."
  @spec list(Client.t(), map(), keyword()) ::
          {:ok, %{items: [map()], meta: map()}}
          | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def list(%Client{} = client, params \\ %{}, opts \\ []) do
    Resource.list(client, @base_path, @resource_key, params, opts)
  end

  @doc "Returns a lazy `Stream` over all pages of outbound payments."
  @spec stream(Client.t(), map(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.stream(client, @base_path, params, @resource_key, opts)
  end

  @doc "Eagerly collects all outbound payments into a list."
  @spec collect_all(Client.t(), map(), keyword()) ::
          {:ok, [map()]} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def collect_all(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.collect(client, @base_path, params, @resource_key, opts)
  end

  @doc "Updates an outbound payment's metadata. Only possible before execution."
  @spec update(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def update(%Client{} = client, id, params, opts \\ []) do
    Resource.update(client, "#{@base_path}/#{id}", @resource_key, params, opts)
  end

  @doc "Cancels an outbound payment before it is executed."
  @spec cancel(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def cancel(%Client{} = client, id, params \\ %{}, opts \\ []) do
    Resource.action(client, "#{@base_path}/#{id}", "cancel", @resource_key, params, opts)
  end

  @doc """
  Approves an outbound payment that is pending approval.

  SCA (Strong Customer Authentication) must be completed before calling this.
  The `:signer` option is required.
  """
  @spec approve(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def approve(%Client{} = client, id, params \\ %{}, opts \\ []) do
    Resource.action(client, "#{@base_path}/#{id}", "approve", @resource_key, params, opts)
  end

  @doc """
  Returns aggregate statistics for outbound payments.

  Returns counts and total amounts grouped by status and currency.
  """
  @spec statistics(Client.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def statistics(%Client{} = client, params \\ %{}, opts \\ []) do
    qs = Resource.build_query(params)
    path = if qs == "", do: "#{@base_path}/statistics", else: "#{@base_path}/statistics?#{qs}"

    case HTTP.Client.request(client.config, :get, path, opts) do
      {:ok, body} -> {:ok, body}
      err -> err
    end
  end
end
