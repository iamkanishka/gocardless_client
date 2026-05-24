defmodule GoCardlessClient.Resources.BankAuthorisations do
  @moduledoc """
  GoCardless Bank Authorisations API.

  Bank Authorisations are created during Open Banking flows. When a customer
  needs to authorise via their bank (Instant Bank Payment or Verified Mandate),
  a Bank Authorisation is created and the customer is redirected to their bank.

  ## Example

      {:ok, auth} = GoCardlessClient.Resources.BankAuthorisations.create(client, %{
        authorisation_type: "payment",
        links: %{billing_request: "BRQ123"}
      })

      # Redirect customer to auth["authorisation_url"]
      # Then poll or use webhooks to detect completion:
      {:ok, updated} = GoCardlessClient.Resources.BankAuthorisations.get(client, auth["id"])
      IO.inspect(updated["status"])  # "authorised", "denied", "expired", etc.
  """

  alias GoCardlessClient.{Client, Resource}

  @resource_key "bank_authorisations"
  @base_path "/bank_authorisations"

  @doc """
  Creates a Bank Authorisation for a Billing Request.

  ## Params

  - `:authorisation_type` — `"mandate"` or `"payment"` (required)
  - `:redirect_uri` — where to redirect after bank auth (optional)
  - `links.billing_request` — Billing Request ID (required)
  """
  @spec create(Client.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def create(%Client{} = client, params, opts \\ []) do
    Resource.post(client, @base_path, @resource_key, params, opts)
  end

  @doc "Retrieves a Bank Authorisation by ID. Poll this to detect status changes."
  @spec get(Client.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def get(%Client{} = client, id, opts \\ []) do
    Resource.get(client, "#{@base_path}/#{id}", @resource_key, opts)
  end
end
