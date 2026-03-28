defmodule GoCardlessClient.Resources.BillingRequests do
  @moduledoc """
  GoCardlessClient Billing Requests API.

  Billing Requests power Open Banking (Pay by Bank) and Variable Recurring Payments.
  They can collect a one-off payment, set up a mandate, or both simultaneously.

  ## Example — instant bank payment

      {:ok, br} = GoCardlessClient.Resources.BillingRequests.create(client, %{
        payment_request: %{amount: 5000, currency: "GBP", description: "Order #1234"}
      })

  ## Example — mandate + instant first payment

      {:ok, br} = GoCardlessClient.Resources.BillingRequests.create(client, %{
        payment_request: %{amount: 10000, currency: "GBP"},
        mandate_request: %{currency: "GBP", scheme: "bacs"}
      })
  """

  alias GoCardlessClient.{Client, Paginator, Resource}

  @resource_key "billing_requests"
  @base_path "/billing_requests"

  @doc "Creates a Billing Request. Accepts `:payment_request`, `:mandate_request`, or both."
  @spec create(Client.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def create(%Client{} = client, params, opts \\ []) do
    Resource.post(client, @base_path, @resource_key, params, opts)
  end

  @doc "Retrieves a single Billing Request by ID."
  @spec get(Client.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def get(%Client{} = client, id, opts \\ []) do
    Resource.get(client, "#{@base_path}/#{id}", @resource_key, opts)
  end

  @doc "Updates a Billing Request's metadata."
  @spec update(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def update(%Client{} = client, id, params, opts \\ []) do
    Resource.put(client, "#{@base_path}/#{id}", @resource_key, params, opts)
  end

  @doc "Returns a page of Billing Requests with optional filters."
  @spec list(Client.t(), map(), keyword()) ::
          {:ok, %{items: [map()], meta: map()}}
          | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def list(%Client{} = client, params \\ %{}, opts \\ []) do
    Resource.list(client, @base_path, @resource_key, params, opts)
  end

  @doc "Returns a lazy `Stream` over all pages of Billing Requests."
  @spec stream(Client.t(), map(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.stream(client, @base_path, params, @resource_key, opts)
  end

  @doc "Eagerly collects all Billing Requests into a list."
  @spec collect_all(Client.t(), map(), keyword()) ::
          {:ok, [map()]} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def collect_all(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.collect(client, @base_path, params, @resource_key, opts)
  end

  @doc "Collects customer details for a Billing Request (server-side flow)."
  @spec collect_customer_details(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def collect_customer_details(%Client{} = client, id, params \\ %{}, opts \\ []) do
    Resource.action(
      client,
      "#{@base_path}/#{id}",
      "collect_customer_details",
      @resource_key,
      params,
      opts
    )
  end

  @doc "Collects bank account details for a Billing Request (server-side flow)."
  @spec collect_bank_account(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def collect_bank_account(%Client{} = client, id, params \\ %{}, opts \\ []) do
    Resource.action(
      client,
      "#{@base_path}/#{id}",
      "collect_bank_account",
      @resource_key,
      params,
      opts
    )
  end

  @doc "Confirms the payer details for a Billing Request."
  @spec confirm_payer_details(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def confirm_payer_details(%Client{} = client, id, params \\ %{}, opts \\ []) do
    Resource.action(
      client,
      "#{@base_path}/#{id}",
      "confirm_payer_details",
      @resource_key,
      params,
      opts
    )
  end

  @doc "Fulfils a Billing Request, creating the payment and/or mandate."
  @spec fulfil(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def fulfil(%Client{} = client, id, params \\ %{}, opts \\ []) do
    Resource.action(client, "#{@base_path}/#{id}", "fulfil", @resource_key, params, opts)
  end

  @doc "Cancels a Billing Request before it is fulfilled."
  @spec cancel(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def cancel(%Client{} = client, id, params \\ %{}, opts \\ []) do
    Resource.action(client, "#{@base_path}/#{id}", "cancel", @resource_key, params, opts)
  end

  @doc "Sends a notification to the customer for a Billing Request."
  @spec notify(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def notify(%Client{} = client, id, params \\ %{}, opts \\ []) do
    Resource.action(client, "#{@base_path}/#{id}", "notify", @resource_key, params, opts)
  end

  @doc "Triggers the fallback flow for a Billing Request."
  @spec fallback(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def fallback(%Client{} = client, id, params \\ %{}, opts \\ []) do
    Resource.action(client, "#{@base_path}/#{id}", "fallback", @resource_key, params, opts)
  end

  @doc "Changes the currency of a Billing Request."
  @spec change_currency(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def change_currency(%Client{} = client, id, params \\ %{}, opts \\ []) do
    Resource.action(client, "#{@base_path}/#{id}", "change_currency", @resource_key, params, opts)
  end

  @doc "Selects the institution (bank) for Open Banking authorisation."
  @spec select_institution(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def select_institution(%Client{} = client, id, params \\ %{}, opts \\ []) do
    Resource.action(
      client,
      "#{@base_path}/#{id}",
      "select_institution",
      @resource_key,
      params,
      opts
    )
  end
end
