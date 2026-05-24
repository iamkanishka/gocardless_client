defmodule GoCardlessClient.Resources.TaxRates do
  @moduledoc """
  GoCardless Tax Rates API.

  Tax rates applied to GoCardless fees for VAT/GST accounting in applicable
  jurisdictions. Read-only — managed by GoCardless.

  ## Example

      {:ok, %{items: rates}} = GoCardlessClient.Resources.TaxRates.list(client)
      current = Enum.find(rates, &is_nil(&1["end_date"]))
  """

  alias GoCardlessClient.{Client, Paginator, Resource}

  @resource_key "tax_rates"
  @base_path "/tax_rates"

  @doc "Retrieves a single tax rate by ID."
  @spec get(Client.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def get(%Client{} = client, id, opts \\ []) do
    Resource.get(client, "#{@base_path}/#{id}", @resource_key, opts)
  end

  @doc "Returns a page of tax rates."
  @spec list(Client.t(), map(), keyword()) ::
          {:ok, %{items: [map()], meta: map()}}
          | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def list(%Client{} = client, params \\ %{}, opts \\ []) do
    Resource.list(client, @base_path, @resource_key, params, opts)
  end

  @doc "Returns a lazy `Stream` over all pages of tax rates."
  @spec stream(Client.t(), map(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.stream(client, @base_path, params, @resource_key, opts)
  end

  @doc "Eagerly collects all tax rates into a list."
  @spec collect_all(Client.t(), map(), keyword()) ::
          {:ok, [map()]} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def collect_all(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.collect(client, @base_path, params, @resource_key, opts)
  end
end
