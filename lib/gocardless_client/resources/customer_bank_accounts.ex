defmodule GoCardlessClient.Resources.CustomerBankAccounts do
  @moduledoc """
  GoCardlessClient Customer Bank Accounts API.

  Customer Bank Accounts represent bank accounts belonging to customers.
  They are used as the funding source for mandates.

  ## Example

      {:ok, account} = GoCardlessClient.Resources.CustomerBankAccounts.create(client, %{
        account_holder_name: "Alice Smith",
        account_number: "55779911",
        branch_code: "200000",
        country_code: "GB",
        links: %{customer: "CU123"}
      })
  """

  alias GoCardlessClient.{Client, Paginator, Resource}

  @resource_key "customer_bank_accounts"
  @base_path "/customer_bank_accounts"

  @doc "Creates a customer bank account. Requires account details and a customer link."
  @spec create(Client.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def create(%Client{} = client, params, opts \\ []) do
    Resource.post(client, @base_path, @resource_key, params, opts)
  end

  @doc "Retrieves a single customer bank account by ID."
  @spec get(Client.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def get(%Client{} = client, id, opts \\ []) do
    Resource.get(client, "#{@base_path}/#{id}", @resource_key, opts)
  end

  @doc "Updates a customer bank account's metadata."
  @spec update(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def update(%Client{} = client, id, params, opts \\ []) do
    Resource.put(client, "#{@base_path}/#{id}", @resource_key, params, opts)
  end

  @doc "Returns a page of customer bank accounts with optional filters."
  @spec list(Client.t(), map(), keyword()) ::
          {:ok, %{items: [map()], meta: map()}}
          | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def list(%Client{} = client, params \\ %{}, opts \\ []) do
    Resource.list(client, @base_path, @resource_key, params, opts)
  end

  @doc "Returns a lazy `Stream` over all pages of customer bank accounts."
  @spec stream(Client.t(), map(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.stream(client, @base_path, params, @resource_key, opts)
  end

  @doc "Eagerly collects all customer bank accounts into a list."
  @spec collect_all(Client.t(), map(), keyword()) ::
          {:ok, [map()]} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def collect_all(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.collect(client, @base_path, params, @resource_key, opts)
  end

  @doc "Disables a bank account. It can no longer be used for new mandates."
  @spec disable(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def disable(%Client{} = client, id, params \\ %{}, opts \\ []) do
    Resource.action(client, "#{@base_path}/#{id}", "disable", @resource_key, params, opts)
  end
end
