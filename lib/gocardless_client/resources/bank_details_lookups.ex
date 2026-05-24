defmodule GoCardlessClient.Resources.BankDetailsLookups do
  @moduledoc """
  GoCardless Bank Details Lookups API.

  Validates bank account details and returns bank information from account/routing
  numbers or an IBAN. Use this before creating a Customer Bank Account to catch
  invalid details early.

  The response includes `available_debit_schemes` — the list of Direct Debit
  schemes the account is compatible with (e.g. `["bacs"]`).

  ## Example — UK sort code + account number

      {:ok, result} = GoCardlessClient.Resources.BankDetailsLookups.lookup(client, %{
        account_number: "55779911",
        branch_code: "200000",
        country_code: "GB"
      })

      IO.inspect(result["bank_name"])              # "BARCLAYS BANK PLC"
      IO.inspect(result["available_debit_schemes"]) # ["bacs"]

  ## Example — IBAN

      {:ok, result} = GoCardlessClient.Resources.BankDetailsLookups.lookup(client, %{
        iban: "GB60BARC20000055779911"
      })
  """

  alias GoCardlessClient.{Client, Resource}

  @resource_key "bank_details_lookups"
  @base_path "/bank_details_lookups"

  @doc """
  Performs a bank account details lookup.

  ## Params (provide one of: sort_code + account_number, or iban)

  - `:account_number` — account number (required if no IBAN)
  - `:branch_code` — sort code / routing number / BSB (required if no IBAN)
  - `:country_code` — ISO 3166-1 alpha-2 (required if no IBAN)
  - `:iban` — IBAN (alternative to account_number + branch_code)
  """
  @spec lookup(Client.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def lookup(%Client{} = client, params, opts \\ []) do
    Resource.post(client, @base_path, @resource_key, params, opts)
  end
end
