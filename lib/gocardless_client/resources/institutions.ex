defmodule GoCardlessClient.Resources.Institutions do
  @moduledoc """
  GoCardless Institutions API.

  Lists banks and financial institutions available for Open Banking flows.

  ## Example

      # List all UK institutions
      {:ok, %{items: banks}} = GoCardlessClient.Resources.Institutions.list(client, %{
        country_code: "GB"
      })

      # List institutions available for a specific Billing Request
      {:ok, %{items: banks}} = GoCardlessClient.Resources.Institutions.list_for_billing_request(
        client, "BRQ123", %{country_code: "GB"}
      )
  """

  alias GoCardlessClient.{Client, Paginator, Resource}

  @resource_key "institutions"
  @base_path "/institutions"

  @doc """
  Lists all available institutions for Open Banking flows.

  ## Filter params

  - `:country_code` — ISO 3166-1 alpha-2, e.g. `"GB"`, `"DE"`, `"FR"` (recommended)
  """
  @spec list(Client.t(), map(), keyword()) ::
          {:ok, %{items: [map()], meta: map()}}
          | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def list(%Client{} = client, params \\ %{}, opts \\ []) do
    Resource.list(client, @base_path, @resource_key, params, opts)
  end

  @doc "Returns a lazy `Stream` over all pages of institutions."
  @spec stream(Client.t(), map(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.stream(client, @base_path, params, @resource_key, opts)
  end

  @doc "Eagerly collects all institutions into a list."
  @spec collect_all(Client.t(), map(), keyword()) ::
          {:ok, [map()]} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def collect_all(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.collect(client, @base_path, params, @resource_key, opts)
  end

  @doc """
  Lists institutions relevant to a specific Billing Request.

  Returns only the institutions compatible with the billing request's currency
  and country. Pass `:country_code` to further filter the results.
  """
  @spec list_for_billing_request(Client.t(), String.t(), map(), keyword()) ::
          {:ok, %{items: [map()], meta: map()}}
          | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def list_for_billing_request(%Client{} = client, billing_request_id, params \\ %{}, opts \\ []) do
    path = "/billing_requests/#{billing_request_id}/institutions"
    Resource.list(client, path, @resource_key, params, opts)
  end
end
