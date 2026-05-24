defmodule GoCardlessClient.Resources.Customers do
  @moduledoc """
  GoCardlessClient Customers API.

  Customers represent the people or organisations you collect payments from.
  Each customer can have multiple bank accounts and mandates.

  ## Example

      {:ok, customer} = GoCardlessClient.Resources.Customers.create(client, %{
        email: "alice@example.com",
        given_name: "Alice",
        family_name: "Smith",
        country_code: "GB"
      })
  """

  alias GoCardlessClient.{Client, Paginator, Resource}

  @resource_key "customers"
  @base_path "/customers"

  @doc "Creates a new customer. `:email` is required."
  @spec create(Client.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def create(%Client{} = client, params, opts \\ []) do
    Resource.post(client, @base_path, @resource_key, params, opts)
  end

  @doc "Retrieves a single customer by ID."
  @spec get(Client.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def get(%Client{} = client, id, opts \\ []) do
    Resource.get(client, "#{@base_path}/#{id}", @resource_key, opts)
  end

  @doc "Updates a customer. All params are optional."
  @spec update(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def update(%Client{} = client, id, params, opts \\ []) do
    Resource.update(client, "#{@base_path}/#{id}", @resource_key, params, opts)
  end

  @doc "Returns a page of customers with optional filters (`:email`, `:created_at[gte]`, etc.)."
  @spec list(Client.t(), map(), keyword()) ::
          {:ok, %{items: [map()], meta: map()}}
          | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def list(%Client{} = client, params \\ %{}, opts \\ []) do
    Resource.list(client, @base_path, @resource_key, params, opts)
  end

  @doc "Returns a lazy `Stream` over all pages of customers."
  @spec stream(Client.t(), map(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.stream(client, @base_path, params, @resource_key, opts)
  end

  @doc "Eagerly collects all customers into a list."
  @spec collect_all(Client.t(), map(), keyword()) ::
          {:ok, [map()]} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def collect_all(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.collect(client, @base_path, params, @resource_key, opts)
  end

  @doc "Removes (GDPR-erases) a customer. All associated mandates are cancelled."
  @spec remove(Client.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def remove(%Client{} = client, id, opts \\ []) do
    Resource.delete(client, "#{@base_path}/#{id}", @resource_key, opts)
  end
end
