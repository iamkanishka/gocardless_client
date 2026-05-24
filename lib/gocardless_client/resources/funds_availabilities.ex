defmodule GoCardlessClient.Resources.FundsAvailabilities do
  @moduledoc """
  GoCardless Funds Availabilities API.

  Check whether sufficient funds are available in a Payment Account before
  initiating an outbound payment or withdrawal.

  ## Example

      {:ok, result} = GoCardlessClient.Resources.FundsAvailabilities.check(client, %{
        amount: 50000,
        currency: "GBP"
      })

      if result["available"] do
        # Proceed with outbound payment
      else
        IO.puts("Funds available at: \#{result["available_at"]}")
      end
  """

  alias GoCardlessClient.{Client, Resource}

  @resource_key "funds_availabilities"
  @base_path "/funds_availabilities"

  @doc """
  Checks whether funds are available for a given amount and currency.

  ## Params

  - `:amount` — amount in minor currency units (required)
  - `:currency` — ISO 4217 currency code (required)
  """
  @spec check(Client.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def check(%Client{} = client, params, opts \\ []) do
    Resource.post(client, @base_path, @resource_key, params, opts)
  end
end
