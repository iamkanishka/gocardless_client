defmodule GoCardlessClient.Resources.Balances do
  @moduledoc """
  GoCardless Balances API.

  Returns balance information for the Payment Account(s) associated with your
  creditor. Balances are read-only — there is no create or update endpoint.

  ## Example

      {:ok, %{items: balances}} = GoCardlessClient.Resources.Balances.list(client)
      Enum.each(balances, fn b ->
        IO.puts("\#{b["currency"]}: \#{b["amount"]}")
      end)
  """

  alias GoCardlessClient.{Client, Paginator, Resource}

  @resource_key "balances"
  @base_path "/balances"

  @doc "Returns a page of balances. Accepts optional filter params."
  @spec list(Client.t(), map(), keyword()) ::
          {:ok, %{items: [map()], meta: map()}}
          | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def list(%Client{} = client, params \\ %{}, opts \\ []) do
    Resource.list(client, @base_path, @resource_key, params, opts)
  end

  @doc "Returns a lazy `Stream` over all pages of balances."
  @spec stream(Client.t(), map(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.stream(client, @base_path, params, @resource_key, opts)
  end

  @doc "Eagerly collects all balances into a list."
  @spec collect_all(Client.t(), map(), keyword()) ::
          {:ok, [map()]} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def collect_all(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.collect(client, @base_path, params, @resource_key, opts)
  end
end
