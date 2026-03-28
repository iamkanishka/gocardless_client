defmodule GoCardlessClient.Resources.Mandates do
  @moduledoc """
  GoCardlessClient Mandates API.

  A Mandate is a Direct Debit agreement between a customer and a creditor,
  authorising the creditor to collect payments.

  ## Example

      {:ok, mandate} = GoCardlessClient.Resources.Mandates.create(client, %{
        scheme: "bacs",
        metadata: %{"contract_id" => "C-001"},
        links: %{customer_bank_account: "BA123"}
      })
  """

  alias GoCardlessClient.{Client, Paginator, Resource}

  @resource_key "mandates"
  @base_path "/mandates"

  @doc "Creates a mandate against a customer bank account."
  @spec create(Client.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def create(%Client{} = client, params, opts \\ []) do
    Resource.post(client, @base_path, @resource_key, params, opts)
  end

  @doc "Retrieves a single mandate by ID."
  @spec get(Client.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def get(%Client{} = client, id, opts \\ []) do
    Resource.get(client, "#{@base_path}/#{id}", @resource_key, opts)
  end

  @doc "Updates a mandate's metadata. Only `:metadata` can be changed."
  @spec update(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def update(%Client{} = client, id, params, opts \\ []) do
    Resource.put(client, "#{@base_path}/#{id}", @resource_key, params, opts)
  end

  @doc "Returns a page of mandates with optional filters (`:status`, `:customer`, `:created_at[gte]`, etc.)."
  @spec list(Client.t(), map(), keyword()) ::
          {:ok, %{items: [map()], meta: map()}}
          | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def list(%Client{} = client, params \\ %{}, opts \\ []) do
    Resource.list(client, @base_path, @resource_key, params, opts)
  end

  @doc "Returns a lazy `Stream` over all pages of mandates."
  @spec stream(Client.t(), map(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.stream(client, @base_path, params, @resource_key, opts)
  end

  @doc "Eagerly collects all mandates into a list."
  @spec collect_all(Client.t(), map(), keyword()) ::
          {:ok, [map()]} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def collect_all(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.collect(client, @base_path, params, @resource_key, opts)
  end

  @doc "Cancels a mandate. All future payments against it will also be cancelled."
  @spec cancel(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def cancel(%Client{} = client, id, params \\ %{}, opts \\ []) do
    Resource.action(client, "#{@base_path}/#{id}", "cancel", @resource_key, params, opts)
  end

  @doc "Reinstates a cancelled or failed mandate. Not available for all mandate statuses."
  @spec reinstate(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def reinstate(%Client{} = client, id, params \\ %{}, opts \\ []) do
    Resource.action(client, "#{@base_path}/#{id}", "reinstate", @resource_key, params, opts)
  end
end
