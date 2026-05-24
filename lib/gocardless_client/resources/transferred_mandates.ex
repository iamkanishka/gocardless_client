defmodule GoCardlessClient.Resources.TransferredMandates do
  @moduledoc """
  GoCardless Transferred Mandates API.

  When a UK customer switches their bank account (via the Current Account
  Switch Service), their mandate is automatically transferred to the new account.

  Use this endpoint to retrieve the new encrypted bank account details after
  a mandate transfer event is received via webhook.

  ## Example

      # Handle a mandate.transferred webhook event:
      def handle_event(%{"resource_type" => "mandates", "action" => "transferred"} = event) do
        mandate_id = event["links"]["mandate"]

        {:ok, transfer} = GoCardlessClient.Resources.TransferredMandates.get(
          client,
          mandate_id
        )

        # Decrypt transfer["encrypted_customer_bank_details"] using
        # transfer["encrypted_decryption_key"] and your RSA private key.
      end
  """

  alias GoCardlessClient.{Client, Resource}

  @resource_key "transferred_mandates"
  @base_path "/transferred_mandates"

  @doc """
  Retrieves the updated (encrypted) bank account details for a transferred mandate.

  Returns:
  - `encrypted_customer_bank_details` — AES-encrypted bank details
  - `encrypted_decryption_key` — RSA-encrypted AES key (decrypt with your private key)
  - `public_key_id` — ID of the public key used for encryption
  """
  @spec get(Client.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def get(%Client{} = client, id, opts \\ []) do
    Resource.get(client, "#{@base_path}/#{id}", @resource_key, opts)
  end
end
