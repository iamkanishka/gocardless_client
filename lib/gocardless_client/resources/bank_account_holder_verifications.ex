defmodule GoCardlessClient.Resources.BankAccountHolderVerifications do
  @moduledoc """
  GoCardless Bank Account Holder Verifications API (Confirmation of Payee).

  Verifies that a bank account holder name matches an expected value before
  sending money. Useful for fraud prevention in Outbound Payment flows.

  ## Example

      {:ok, verification} = GoCardlessClient.Resources.BankAccountHolderVerifications.create(
        client,
        %{
          account_holder_name: "Alice Smith",
          sort_code: "200000",
          account_number: "55779911"
        }
      )

      case verification["result"] do
        "pass" -> :proceed
        "fail" -> :abort
        "inconclusive" -> :manual_review
      end
  """

  alias GoCardlessClient.{Client, Resource}

  @resource_key "bank_account_holder_verifications"
  @base_path "/bank_account_holder_verifications"

  @doc """
  Creates a bank account holder verification (Confirmation of Payee).

  ## Params (provide one of: sort_code + account_number, or iban)

  - `:account_holder_name` — the name to verify (required)
  - `:sort_code` — UK sort code 6 digits
  - `:account_number` — UK account number 8 digits
  - `:iban` — IBAN for SEPA accounts
  """
  @spec create(Client.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def create(%Client{} = client, params, opts \\ []) do
    Resource.post(client, @base_path, @resource_key, params, opts)
  end

  @doc "Retrieves a single bank account holder verification by ID."
  @spec get(Client.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def get(%Client{} = client, id, opts \\ []) do
    Resource.get(client, "#{@base_path}/#{id}", @resource_key, opts)
  end
end
