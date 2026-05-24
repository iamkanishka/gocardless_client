defmodule GoCardlessClient.Resources.OutboundPaymentImportEntries do
  @moduledoc """
  GoCardless Outbound Payment Import Entries API.

  Individual payment entries within an Outbound Payment Import batch.

  ## Example

      {:ok, %{items: entries}} = GoCardlessClient.Resources.OutboundPaymentImportEntries.list(
        client,
        %{outbound_payment_import: "OPI123"}
      )
  """

  alias GoCardlessClient.{Client, Paginator, Resource}

  @resource_key "outbound_payment_import_entries"
  @base_path "/outbound_payment_import_entries"

  @doc """
  Lists all entries for an outbound payment import.

  The `:outbound_payment_import` filter is required.
  """
  @spec list(Client.t(), map(), keyword()) ::
          {:ok, %{items: [map()], meta: map()}}
          | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def list(%Client{} = client, params \\ %{}, opts \\ []) do
    Resource.list(client, @base_path, @resource_key, params, opts)
  end

  @doc "Returns a lazy `Stream` over all entries in an outbound payment import."
  @spec stream(Client.t(), map(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.stream(client, @base_path, params, @resource_key, opts)
  end

  @doc "Eagerly collects all import entries into a list."
  @spec collect_all(Client.t(), map(), keyword()) ::
          {:ok, [map()]} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def collect_all(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.collect(client, @base_path, params, @resource_key, opts)
  end
end
