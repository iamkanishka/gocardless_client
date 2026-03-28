defmodule GoCardlessClient.Resources.RedirectFlows do
  @moduledoc """
  GoCardlessClient Redirect Flows API.

  Redirect Flows provide a GoCardlessClient-hosted mandate setup page.
  No payment page restrictions apply.

  ## Example

      session_token = GoCardlessClient.new_idempotency_key()

      {:ok, flow} = GoCardlessClient.Resources.RedirectFlows.create(client, %{
        description: "Set up your Direct Debit",
        session_token: session_token,
        success_redirect_url: "https://example.com/mandate-confirmed",
        scheme: "bacs",
        prefilled_customer: %{
          given_name: "Alice",
          family_name: "Smith",
          email: "alice@example.com",
          country_code: "GB"
        }
      })

      # Redirect customer to flow["redirect_url"]

      # After customer completes and is redirected back:
      {:ok, completed} = GoCardlessClient.Resources.RedirectFlows.complete(
        client, flow["id"], session_token
      )
      mandate_id  = get_in(completed, ["links", "mandate"])
      customer_id = get_in(completed, ["links", "customer"])
  """

  alias GoCardlessClient.{Client, Resource}

  @resource_key "redirect_flows"
  @base_path "/redirect_flows"

  @doc """
  Creates a Redirect Flow.

  Returns the flow including `redirect_url` — redirect the customer there
  to complete mandate setup on the GoCardlessClient-hosted page.

  ## Required params

  - `:description` — shown to the customer on the payment page
  - `:session_token` — unique per session; matched during `complete/4`
  - `:success_redirect_url` — where to send the customer after completion

  ## Optional params

  - `:scheme` — e.g. `"bacs"`, `"sepa_core"`, `"autogiro"`
  - `:prefilled_customer` — pre-fill customer details to reduce friction
  - `:prefilled_bank_account` — pre-fill bank account details
  - `links.creditor` — creditor to use (required for some schemes)
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
  Completes a Redirect Flow after the customer returns from the hosted page.

  The `session_token` must match the one used when creating the flow.

  On success, the returned map has `links.mandate` and `links.customer`
  populated with the newly created resource IDs.
  """
  @spec complete(Client.t(), String.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, term()}
  def complete(%Client{} = client, id, session_token, opts \\ []) do
    params = %{"session_token" => session_token}
    Resource.action(client, "#{@base_path}/#{id}", "complete", @resource_key, params, opts)
  end
end
