defmodule GoCardlessClient.Resources.RedirectFlows do
  @moduledoc """
  GoCardless Redirect Flows API (Legacy).

  **This is a legacy API.** New integrations should use
  `GoCardlessClient.Resources.BillingRequestFlows` instead, which supports
  Open Banking, fallback flows, and more flexible customisation.

  Redirect Flows create a GoCardless-hosted page where a customer sets up a
  Direct Debit mandate. After the customer completes the flow, you must call
  `complete/3` with the original session token to create the mandate.

  ## Example

      {:ok, flow} = GoCardlessClient.Resources.RedirectFlows.create(client, %{
        description: "Set up your Direct Debit",
        session_token: "unique-session-token",
        success_redirect_url: "https://myapp.com/mandate-complete"
      })

      # Redirect customer to flow["redirect_url"]

      # After redirect back:
      {:ok, completed} = GoCardlessClient.Resources.RedirectFlows.complete(
        client,
        flow["id"],
        %{session_token: "unique-session-token"}
      )

      mandate_id = completed["links"]["mandate"]
  """

  alias GoCardlessClient.{Client, Paginator, Resource}

  @resource_key "redirect_flows"
  @base_path "/redirect_flows"

  @doc """
  Creates a Redirect Flow and returns a hosted `redirect_url`.

  ## Params

  - `:description` — shown on the GoCardless-hosted page (required)
  - `:session_token` — unique token tying this session to your user (required)
  - `:success_redirect_url` — where to redirect after completion (required)
  - `:prefilled_customer` — map of customer details to pre-populate
  - `:scheme` — Direct Debit scheme (optional)
  - `links.creditor` — Creditor ID if managing multiple creditors (optional)
  """
  @spec create(Client.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def create(%Client{} = client, params, opts \\ []) do
    Resource.post(client, @base_path, @resource_key, params, opts)
  end

  @doc "Retrieves a single Redirect Flow by ID."
  @spec get(Client.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def get(%Client{} = client, id, opts \\ []) do
    Resource.get(client, "#{@base_path}/#{id}", @resource_key, opts)
  end

  @doc """
  Lists redirect flows. Filter by `:created_at[gte]`, `:created_at[lte]`.
  """
  @spec list(Client.t(), map(), keyword()) ::
          {:ok, %{items: [map()], meta: map()}}
          | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def list(%Client{} = client, params \\ %{}, opts \\ []) do
    Resource.list(client, @base_path, @resource_key, params, opts)
  end

  @doc "Returns a lazy `Stream` over all pages of redirect flows."
  @spec stream(Client.t(), map(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.stream(client, @base_path, params, @resource_key, opts)
  end

  @doc "Eagerly collects all redirect flows into a list."
  @spec collect_all(Client.t(), map(), keyword()) ::
          {:ok, [map()]} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def collect_all(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.collect(client, @base_path, params, @resource_key, opts)
  end

  @doc """
  Completes a Redirect Flow after the customer has returned from GoCardless.

  Must be called with the same `:session_token` used at creation.
  Returns the created mandate and customer IDs in `links`.
  """
  @spec complete(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def complete(%Client{} = client, id, params, opts \\ []) do
    Resource.action(client, "#{@base_path}/#{id}", "complete", @resource_key, params, opts)
  end
end
