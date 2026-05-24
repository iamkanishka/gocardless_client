defmodule GoCardlessClient.Resources.MandatePDFs do
  @moduledoc """
  GoCardless Mandate PDFs API.

  Generates a PDF copy of a mandate for record-keeping, compliance, or delivery
  to the customer. The response contains a time-limited download URL.

  ## Example

      {:ok, pdf} = GoCardlessClient.Resources.MandatePDFs.create(client, %{
        links: %{mandate: "MD123"}
      })

      IO.puts("Download PDF from: \#{pdf["url"]} (expires at \#{pdf["expires_at"]})")
  """

  alias GoCardlessClient.{Client, Resource}

  @resource_key "mandate_pdfs"
  @base_path "/mandate_pdfs"

  @doc """
  Creates a mandate PDF and returns a time-limited download URL.

  ## Params (provide one of: mandate link or pre-creation fields)

  - `links.mandate` — generate PDF for an existing mandate
  - `links.billing_request` — generate PDF from a billing request
  - `:account_holder_name` / `:account_number` / `:branch_code` / `:iban` — for pre-creation PDFs
  - `:mandate_reference` — reference to show on PDF
  - `:scheme` — scheme for pre-creation PDFs
  - `:signatory_name` — name of signatory
  - `:signatory_address` — address map
  - `:subscription_amount` — show subscription amount on PDF
  - `:subscription_frequency` — e.g. `"monthly"`
  """
  @spec create(Client.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def create(%Client{} = client, params, opts \\ []) do
    Resource.post(client, @base_path, @resource_key, params, opts)
  end
end
