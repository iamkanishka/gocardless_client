defmodule GoCardlessClient.Resources.CurrencyExchangeRates do
  @moduledoc """
  GoCardless Currency Exchange Rates API.

  Returns current exchange rates used by GoCardless for FX collections
  and payouts. Read-only — there is no create or update endpoint.
  """

  alias GoCardlessClient.{Client, Paginator, Resource}

  @resource_key "currency_exchange_rates"
  @base_path "/currency_exchange_rates"

  @doc "Returns a page of exchange rates. Filter by `:source` currency."
  @spec list(Client.t(), map(), keyword()) ::
          {:ok, %{items: [map()], meta: map()}}
          | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def list(%Client{} = client, params \\ %{}, opts \\ []) do
    Resource.list(client, @base_path, @resource_key, params, opts)
  end

  @doc "Returns a lazy `Stream` over all pages of exchange rates."
  @spec stream(Client.t(), map(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.stream(client, @base_path, params, @resource_key, opts)
  end

  @doc "Eagerly collects all exchange rates into a list."
  @spec collect_all(Client.t(), map(), keyword()) ::
          {:ok, [map()]} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def collect_all(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.collect(client, @base_path, params, @resource_key, opts)
  end
end
