defmodule GoCardlessClient.Resources.BillingRequestTemplates do
  @moduledoc """
  GoCardless Billing Request Templates API.

  Reusable templates for creating Billing Requests with pre-defined parameters.
  Useful for recurring setups where the same mandate/payment configuration
  is used many times (e.g. a SaaS signup flow).

  ## Example

      {:ok, template} = GoCardlessClient.Resources.BillingRequestTemplates.create(client, %{
        name: "Standard Monthly DD",
        mandate_request_currency: "GBP",
        mandate_request_scheme: "bacs",
        redirect_uri: "https://myapp.com/complete"
      })

      # Later, create a billing request from the template
  """

  alias GoCardlessClient.{Client, Paginator, Resource}

  @resource_key "billing_request_templates"
  @base_path "/billing_request_templates"

  @doc "Creates a Billing Request Template."
  @spec create(Client.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def create(%Client{} = client, params, opts \\ []) do
    Resource.post(client, @base_path, @resource_key, params, opts)
  end

  @doc "Retrieves a single Billing Request Template by ID."
  @spec get(Client.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def get(%Client{} = client, id, opts \\ []) do
    Resource.get(client, "#{@base_path}/#{id}", @resource_key, opts)
  end

  @doc "Returns a page of Billing Request Templates with optional filters."
  @spec list(Client.t(), map(), keyword()) ::
          {:ok, %{items: [map()], meta: map()}}
          | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def list(%Client{} = client, params \\ %{}, opts \\ []) do
    Resource.list(client, @base_path, @resource_key, params, opts)
  end

  @doc "Returns a lazy `Stream` over all pages of Billing Request Templates."
  @spec stream(Client.t(), map(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.stream(client, @base_path, params, @resource_key, opts)
  end

  @doc "Eagerly collects all Billing Request Templates into a list."
  @spec collect_all(Client.t(), map(), keyword()) ::
          {:ok, [map()]} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def collect_all(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.collect(client, @base_path, params, @resource_key, opts)
  end

  @doc "Updates a Billing Request Template. All params are optional."
  @spec update(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def update(%Client{} = client, id, params, opts \\ []) do
    Resource.update(client, "#{@base_path}/#{id}", @resource_key, params, opts)
  end
end
