defmodule GoCardlessClient.Resources.NegativeBalanceLimits do
  @moduledoc """
  GoCardless Negative Balance Limits API.

  Returns the configured limits on how negative a creditor's balance can go
  before payouts are automatically paused. This can happen when refunds,
  chargebacks, or fees exceed collected payments.

  These limits are configured by GoCardless — they cannot be created or updated
  via the API.
  """

  alias GoCardlessClient.{Client, Paginator, Resource}

  @resource_key "negative_balance_limits"
  @base_path "/negative_balance_limits"

  @doc "Returns a page of negative balance limits."
  @spec list(Client.t(), map(), keyword()) ::
          {:ok, %{items: [map()], meta: map()}}
          | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def list(%Client{} = client, params \\ %{}, opts \\ []) do
    Resource.list(client, @base_path, @resource_key, params, opts)
  end

  @doc "Returns a lazy `Stream` over all negative balance limits."
  @spec stream(Client.t(), map(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.stream(client, @base_path, params, @resource_key, opts)
  end

  @doc "Eagerly collects all negative balance limits into a list."
  @spec collect_all(Client.t(), map(), keyword()) ::
          {:ok, [map()]} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def collect_all(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.collect(client, @base_path, params, @resource_key, opts)
  end
end
