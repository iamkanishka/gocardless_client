defmodule GoCardlessClient.Resources.OutboundPaymentImports do
  @moduledoc """
  GoCardless Outbound Payment Imports API.

  Bulk creation of outbound payments via an import batch. Useful for processing
  payroll, supplier payments, or any scenario with many outbound payments at once.

  ## Workflow

  1. Create an import: `create/3`
  2. Add import entries: `GoCardlessClient.Resources.OutboundPaymentImportEntries`
  3. GoCardless processes entries and sends events/webhooks per payment

  ## Import states

  `created` → `processing` → `completed` / `failed`

  ## Example

      {:ok, import} = GoCardlessClient.Resources.OutboundPaymentImports.create(client, %{
        currency: "GBP",
        links: %{payment_account: "PA123"}
      })
  """

  alias GoCardlessClient.{Client, Paginator, Resource}

  @resource_key "outbound_payment_imports"
  @base_path "/outbound_payment_imports"

  @doc """
  Creates a new outbound payment import batch.

  ## Params

  - `:currency` — ISO 4217 currency code for all payments in this batch (required)
  - `links.payment_account` — the Payment Account to fund from (required)
  """
  @spec create(Client.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def create(%Client{} = client, params, opts \\ []) do
    Resource.post(client, @base_path, @resource_key, params, opts)
  end

  @doc "Retrieves a single outbound payment import by ID."
  @spec get(Client.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def get(%Client{} = client, id, opts \\ []) do
    Resource.get(client, "#{@base_path}/#{id}", @resource_key, opts)
  end

  @doc "Returns a page of outbound payment imports."
  @spec list(Client.t(), map(), keyword()) ::
          {:ok, %{items: [map()], meta: map()}}
          | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def list(%Client{} = client, params \\ %{}, opts \\ []) do
    Resource.list(client, @base_path, @resource_key, params, opts)
  end

  @doc "Returns a lazy `Stream` over all pages of outbound payment imports."
  @spec stream(Client.t(), map(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.stream(client, @base_path, params, @resource_key, opts)
  end

  @doc "Eagerly collects all outbound payment imports into a list."
  @spec collect_all(Client.t(), map(), keyword()) ::
          {:ok, [map()]} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def collect_all(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.collect(client, @base_path, params, @resource_key, opts)
  end
end
