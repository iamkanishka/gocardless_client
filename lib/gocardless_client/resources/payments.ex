defmodule GoCardlessClient.Resources.Payments do
  @moduledoc """
  GoCardlessClient Payments API.

  Payments are the core of GoCardlessClient — they represent money being pulled
  from a customer's bank account on a mandate.

  ## Example

      {:ok, payment} = GoCardlessClient.Resources.Payments.create(client, %{
        amount: 1500,
        currency: "GBP",
        description: "Monthly service fee",
        links: %{mandate: "MD123"}
      }, idempotency_key: GoCardlessClient.new_idempotency_key())
  """

  alias GoCardlessClient.{Client, Paginator, Resource}

  @resource_key "payments"
  @base_path "/payments"

  @doc "Creates a payment against an existing mandate. Always pass an idempotency key to make retries safe."
  @spec create(Client.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def create(%Client{} = client, params, opts \\ []) do
    Resource.post(client, @base_path, @resource_key, params, opts)
  end

  @doc "Retrieves a single payment by ID."
  @spec get(Client.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def get(%Client{} = client, id, opts \\ []) do
    Resource.get(client, "#{@base_path}/#{id}", @resource_key, opts)
  end

  @doc "Updates a payment's description or metadata. Only possible before submission."
  @spec update(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def update(%Client{} = client, id, params, opts \\ []) do
    Resource.update(client, "#{@base_path}/#{id}", @resource_key, params, opts)
  end

  @doc "Returns a single page of payments with optional filters (`:status`, `:mandate`, `:customer`, `:created_at[gte]`, etc.)."
  @spec list(Client.t(), map(), keyword()) ::
          {:ok, %{items: [map()], meta: map()}}
          | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def list(%Client{} = client, params \\ %{}, opts \\ []) do
    Resource.list(client, @base_path, @resource_key, params, opts)
  end

  @doc "Returns a lazy `Stream` over all pages of payments. Efficient for large datasets."
  @spec stream(Client.t(), map(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.stream(client, @base_path, params, @resource_key, opts)
  end

  @doc "Eagerly collects all payments into a list. Use `stream/3` for large datasets."
  @spec collect_all(Client.t(), map(), keyword()) ::
          {:ok, [map()]} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def collect_all(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.collect(client, @base_path, params, @resource_key, opts)
  end

  @doc "Cancels a payment. Only possible before it is submitted to the banks."
  @spec cancel(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def cancel(%Client{} = client, id, params \\ %{}, opts \\ []) do
    Resource.action(client, "#{@base_path}/#{id}", "cancel", @resource_key, params, opts)
  end

  @doc "Retries a failed payment on a new charge date."
  @spec retry(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def retry(%Client{} = client, id, params \\ %{}, opts \\ []) do
    Resource.action(client, "#{@base_path}/#{id}", "retry", @resource_key, params, opts)
  end
end
