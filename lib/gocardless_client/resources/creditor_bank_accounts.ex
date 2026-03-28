defmodule GoCardlessClient.Resources.CreditorBankAccounts do
  @moduledoc """
  GoCardlessClient Creditor Bank Accounts API.

  See https://developer.gocardless.com/api-reference/#creditor-bank-accounts for full documentation.
  """

  alias GoCardlessClient.{Client, Paginator, Resource}

  @resource_key "creditor_bank_accounts"
  @base_path "/creditor_bank_accounts"

  @doc "Creates a new creditor bank accounts resource."
  @spec create(Client.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def create(%Client{} = client, params, opts \\ []) do
    Resource.post(client, @base_path, @resource_key, params, opts)
  end

  @doc "Retrieves a single creditor bank accounts by ID."
  @spec get(Client.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def get(%Client{} = client, id, opts \\ []) do
    Resource.get(client, "#{@base_path}/#{id}", @resource_key, opts)
  end

  @doc "Updates a creditor bank accounts."
  @spec update(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def update(%Client{} = client, id, params, opts \\ []) do
    Resource.put(client, "#{@base_path}/#{id}", @resource_key, params, opts)
  end

  @doc "Lists creditor_bank_accounts with optional filter params."
  @spec list(Client.t(), map(), keyword()) ::
          {:ok, %{items: [map()], meta: map()}}
          | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def list(%Client{} = client, params \\ %{}, opts \\ []) do
    Resource.list(client, @base_path, @resource_key, params, opts)
  end

  @doc "Returns a lazy `Stream` over all pages of creditor_bank_accounts."
  @spec stream(Client.t(), map(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.stream(client, @base_path, params, @resource_key, opts)
  end

  @doc "Eagerly collects all creditor_bank_accounts into a list across all pages."
  @spec collect_all(Client.t(), map(), keyword()) ::
          {:ok, [map()]} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def collect_all(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.collect(client, @base_path, params, @resource_key, opts)
  end

  @doc "Disables a creditor bank account."
  @spec disable(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def disable(%Client{} = client, id, params \\ %{}, opts \\ []) do
    Resource.action(client, "#{@base_path}/#{id}", "disable", @resource_key, params, opts)
  end
end
