defmodule GoCardlessClient.Resources.Payouts do
  @moduledoc """
  GoCardless Payouts API.

  Payouts are batched settlements from GoCardless to your creditor bank account.
  GoCardless aggregates collected payments and sends periodic payouts.

  ## Payout states

  `pending` → `paid`

  ## Example

      {:ok, %{items: payouts}} = GoCardlessClient.Resources.Payouts.list(client, %{
        status: "paid",
        currency: "GBP"
      })
  """

  alias GoCardlessClient.{Client, Paginator, Resource}

  @resource_key "payouts"
  @base_path "/payouts"

  @doc "Retrieves a single payout by ID."
  @spec get(Client.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def get(%Client{} = client, id, opts \\ []) do
    Resource.get(client, "#{@base_path}/#{id}", @resource_key, opts)
  end

  @doc """
  Returns a page of payouts.

  Filter by `:creditor`, `:creditor_bank_account`, `:currency`, `:status`,
  `:created_at[gte]`, `:created_at[lte]`, `:payout_type` (`"merchant"` or `"partner"`).
  """
  @spec list(Client.t(), map(), keyword()) ::
          {:ok, %{items: [map()], meta: map()}}
          | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def list(%Client{} = client, params \\ %{}, opts \\ []) do
    Resource.list(client, @base_path, @resource_key, params, opts)
  end

  @doc "Returns a lazy `Stream` over all pages of payouts."
  @spec stream(Client.t(), map(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.stream(client, @base_path, params, @resource_key, opts)
  end

  @doc "Eagerly collects all payouts into a list."
  @spec collect_all(Client.t(), map(), keyword()) ::
          {:ok, [map()]} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def collect_all(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.collect(client, @base_path, params, @resource_key, opts)
  end

  @doc "Updates a payout's metadata. Only `:metadata` can be changed."
  @spec update(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def update(%Client{} = client, id, params, opts \\ []) do
    Resource.update(client, "#{@base_path}/#{id}", @resource_key, params, opts)
  end
end
