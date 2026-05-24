defmodule GoCardlessClient.Resources.PayerAuthorisations do
  @moduledoc """
  GoCardless Payer Authorisations API (Legacy).

  **This is a legacy API.** New integrations should use
  `GoCardlessClient.Resources.BillingRequests` instead, which supports
  Open Banking, fallback flows, and custom UIs.

  Payer Authorisations collect mandate authorisation in a single object.
  They do not support Open Banking.

  ## States

  `created` → `submitted` → `completed` / `failed`

  ## Example

      {:ok, pa} = GoCardlessClient.Resources.PayerAuthorisations.create(client, %{
        payer: %{email: "alice@example.com"},
        bank_account: %{
          account_holder_name: "Alice Smith",
          account_number: "55779911",
          branch_code: "200000",
          country_code: "GB"
        },
        mandate: %{scheme: "bacs"}
      })

      {:ok, _} = GoCardlessClient.Resources.PayerAuthorisations.submit(client, pa["id"])
      {:ok, _} = GoCardlessClient.Resources.PayerAuthorisations.confirm(client, pa["id"])
  """

  alias GoCardlessClient.{Client, Paginator, Resource}

  @resource_key "payer_authorisations"
  @base_path "/payer_authorisations"

  @doc "Creates a Payer Authorisation with customer, bank account, and mandate details."
  @spec create(Client.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def create(%Client{} = client, params, opts \\ []) do
    Resource.post(client, @base_path, @resource_key, params, opts)
  end

  @doc "Retrieves a single Payer Authorisation by ID."
  @spec get(Client.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def get(%Client{} = client, id, opts \\ []) do
    Resource.get(client, "#{@base_path}/#{id}", @resource_key, opts)
  end

  @doc "Returns a page of Payer Authorisations with optional filters."
  @spec list(Client.t(), map(), keyword()) ::
          {:ok, %{items: [map()], meta: map()}}
          | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def list(%Client{} = client, params \\ %{}, opts \\ []) do
    Resource.list(client, @base_path, @resource_key, params, opts)
  end

  @doc "Returns a lazy `Stream` over all pages of Payer Authorisations."
  @spec stream(Client.t(), map(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.stream(client, @base_path, params, @resource_key, opts)
  end

  @doc "Eagerly collects all Payer Authorisations into a list."
  @spec collect_all(Client.t(), map(), keyword()) ::
          {:ok, [map()]} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def collect_all(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.collect(client, @base_path, params, @resource_key, opts)
  end

  @doc "Updates a Payer Authorisation with revised customer, bank account, or mandate details."
  @spec update(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def update(%Client{} = client, id, params, opts \\ []) do
    Resource.update(client, "#{@base_path}/#{id}", @resource_key, params, opts)
  end

  @doc "Submits a Payer Authorisation for customer approval."
  @spec submit(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def submit(%Client{} = client, id, params \\ %{}, opts \\ []) do
    Resource.action(client, "#{@base_path}/#{id}", "submit", @resource_key, params, opts)
  end

  @doc "Confirms a Payer Authorisation after the customer has approved."
  @spec confirm(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def confirm(%Client{} = client, id, params \\ %{}, opts \\ []) do
    Resource.action(client, "#{@base_path}/#{id}", "confirm", @resource_key, params, opts)
  end
end
