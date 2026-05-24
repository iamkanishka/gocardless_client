defmodule GoCardlessClient.Resources.BillingRequestWithActions do
  @moduledoc """
  GoCardless Billing Request with Actions API.

  A simplified single-call API that combines Billing Request creation AND action
  execution in one request. This reduces round-trips when you already have all
  customer details available (e.g. on server-side flows or migrations).

  ## Supported actions (include in the `actions` list)

  - `"collect_customer_details"` — supply customer name, email, address
  - `"collect_bank_account"` — supply bank account details manually
  - `"confirm_payer_details"` — confirm payer (required to move to ready_to_fulfil)
  - `"fulfil"` — fulfil the billing request (create the mandate/payment)

  ## Example — create a mandate in one call

      {:ok, result} = GoCardlessClient.Resources.BillingRequestWithActions.create(client, %{
        mandate_request: %{currency: "GBP", scheme: "bacs"},
        actions: [
          %{
            type: "collect_customer_details",
            collect_customer_details: %{
              customer: %{
                given_name: "Alice",
                family_name: "Smith",
                email: "alice@example.com"
              },
              customer_billing_detail: %{
                address_line1: "1 Example St",
                city: "London",
                postal_code: "EC1A 1BB",
                country_code: "GB"
              }
            }
          },
          %{
            type: "collect_bank_account",
            collect_bank_account: %{
              account_holder_name: "Alice Smith",
              account_number: "55779911",
              branch_code: "200000",
              country_code: "GB"
            }
          },
          %{type: "confirm_payer_details", confirm_payer_details: %{}},
          %{type: "fulfil", fulfil: %{}}
        ]
      })
  """

  alias GoCardlessClient.{Client, Resource}

  @resource_key "billing_requests"
  @base_path "/billing_requests_with_actions"

  @doc """
  Creates a Billing Request and executes actions in a single call.

  ## Params

  - `:mandate_request` — mandate configuration map (optional if payment_request given)
  - `:payment_request` — payment configuration map (optional if mandate_request given)
  - `:actions` — ordered list of action maps to execute (required)
  - `links.customer` — link to existing customer (optional)
  - `links.customer_bank_account` — link to existing bank account (optional)
  - `:fallback_enabled` — enable fallback from Open Banking to DD (optional)
  """
  @spec create(Client.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def create(%Client{} = client, params, opts \\ []) do
    Resource.post(client, @base_path, @resource_key, params, opts)
  end
end
