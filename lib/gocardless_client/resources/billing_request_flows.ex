defmodule GoCardlessClient.Resources.BillingRequestFlows do
  @moduledoc """
  GoCardless Billing Request Flows API.

  A Billing Request Flow generates a hosted URL where the customer completes a
  Billing Request on GoCardless-hosted pages. This is the simplest way to
  integrate — no custom UI needed.

  ## Example

      {:ok, br} = GoCardlessClient.Resources.BillingRequests.create(client, %{
        mandate_request: %{currency: "GBP", scheme: "bacs"}
      })

      {:ok, flow} = GoCardlessClient.Resources.BillingRequestFlows.create(client, %{
        redirect_uri: "https://myapp.com/complete",
        exit_uri: "https://myapp.com/cancel",
        links: %{billing_request: br["id"]}
      })

      # Redirect customer to flow["authorisation_url"]
  """

  alias GoCardlessClient.{Client, Resource}

  @resource_key "billing_request_flows"
  @base_path "/billing_request_flows"

  @doc """
  Creates a Billing Request Flow and returns a hosted `authorisation_url`.

  ## Params

  - `links.billing_request` — Billing Request ID (required)
  - `:redirect_uri` — where to send the customer on success
  - `:exit_uri` — where to send the customer if they abandon
  - `:expiry` — ISO 8601 datetime; when the flow URL expires
  - `:language` — ISO 639-1 language code for the hosted UI (e.g. `"en"`, `"fr"`)
  - `:prefilled_customer` — map of customer details to pre-fill
  - `:show_redirect_buttons` — show back/cancel buttons
  - `:show_success_redirect_button` — show a continue button after success
  - `:lock_currency` — prevent customer changing currency
  - `:lock_bank_account` — prevent customer changing bank account
  - `:lock_customer_details` — lock pre-filled customer details
  """
  @spec create(Client.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def create(%Client{} = client, params, opts \\ []) do
    Resource.post(client, @base_path, @resource_key, params, opts)
  end

  @doc """
  Initialises a Billing Request Flow, generating a fresh `authorisation_url`.

  Use this if the previous URL has expired and you need a new one.
  """
  @spec initialise(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def initialise(%Client{} = client, id, params \\ %{}, opts \\ []) do
    Resource.action(client, "#{@base_path}/#{id}", "initialise", @resource_key, params, opts)
  end
end
