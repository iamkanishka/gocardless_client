defmodule GoCardlessClient.Resources.BankAccountDetails do
  @moduledoc """
  GoCardless Bank Account Details API.

  Returns encrypted bank account details (sort code + account number or IBAN)
  for a customer bank account. Requires special approval from GoCardless —
  not available by default.

  The response includes `encrypted_data` and `encrypted_key` fields that must
  be decrypted using asymmetric key decryption on your side.

  ## Example

      {:ok, details} = GoCardlessClient.Resources.BankAccountDetails.get(
        client,
        %{"links[customer_bank_account]" => "BA123"}
      )
  """

  alias GoCardlessClient.{Client, HTTP}

  @resource_key "bank_account_details"
  @base_path "/bank_account_details"

  @doc """
  Returns encrypted bank details for a customer bank account.

  Pass `%{"links[customer_bank_account]" => "BA123"}` as params.
  """
  @spec get(Client.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def get(%Client{} = client, params \\ %{}, opts \\ []) do
    qs = URI.encode_query(params)
    path = if qs == "", do: @base_path, else: "#{@base_path}?#{qs}"

    case HTTP.Client.request(client.config, :get, path, opts) do
      {:ok, body} -> {:ok, Map.get(body || %{}, @resource_key, body)}
      err -> err
    end
  end
end
