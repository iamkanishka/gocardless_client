defmodule GoCardlessClient.Resources.PaymentAccountTransactions do
  @moduledoc """
  GoCardless Payment Account Transactions API.

  Detailed transaction history within a Payment Account — credits, debits, fees,
  FX conversions, and payouts. All transactions are read-only.

  ## Transaction types

  `payment_paid_in`, `refund_paid_out`, `outbound_payment`, `fee`, `fx_fee`, `payout`
  """

  alias GoCardlessClient.{Client, Paginator, Resource}

  @resource_key "payment_account_transactions"
  @base_path "/payment_account_transactions"

  @doc "Retrieves a single payment account transaction by ID."
  @spec get(Client.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def get(%Client{} = client, id, opts \\ []) do
    Resource.get(client, "#{@base_path}/#{id}", @resource_key, opts)
  end

  @doc """
  Returns a page of transactions.

  Filter by `:payment_account`, `:created_at[gte]`, `:created_at[lte]`, `:transaction_type`.
  """
  @spec list(Client.t(), map(), keyword()) ::
          {:ok, %{items: [map()], meta: map()}}
          | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def list(%Client{} = client, params \\ %{}, opts \\ []) do
    Resource.list(client, @base_path, @resource_key, params, opts)
  end

  @doc "Returns a lazy `Stream` over all pages of transactions."
  @spec stream(Client.t(), map(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.stream(client, @base_path, params, @resource_key, opts)
  end

  @doc "Eagerly collects all transactions into a list."
  @spec collect_all(Client.t(), map(), keyword()) ::
          {:ok, [map()]} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def collect_all(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.collect(client, @base_path, params, @resource_key, opts)
  end
end
