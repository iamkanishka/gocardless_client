defmodule GoCardlessClient.Resources.PayoutItems do
  @moduledoc """
  GoCardless Payout Items API.

  Line items within a payout — shows exactly what contributed to or was deducted
  from a payout amount. Use this for detailed payout reconciliation.

  ## Item types

  | Type | Description |
  |------|-------------|
  | `payment_paid_out` | A payment that cleared |
  | `payment_failed` | A previously included payment that failed |
  | `payment_charged_back` | A chargeback |
  | `payment_refunded` | A refund issued to a customer |
  | `refund_funds_returned` | Refund returned to GoCardless |
  | `gocardless_fee` | GoCardless transaction fee |
  | `app_fee` | Partner app fee |
  | `app_fee_refund` | Refund of app fee |
  | `revenue_share` | Revenue share for partners |
  | `surcharge_fee` | Surcharge for a failed payment |
  | `fx` | FX conversion fee/gain |
  | `tax` | Tax on GoCardless fees |

  Note: Payout items for payouts older than 6 months are archived.
  Contact GoCardless support to access historical items.

  ## Example

      {:ok, %{items: line_items}} = GoCardlessClient.Resources.PayoutItems.list(
        client,
        %{payout: "PO123"}
      )

      total_payments = line_items
        |> Enum.filter(&(&1["type"] == "payment_paid_out"))
        |> Enum.sum_by(&(&1["amount"]["amount"]))
  """

  alias GoCardlessClient.{Client, Paginator, Resource}

  @resource_key "payout_items"
  @base_path "/payout_items"

  @doc """
  Returns all line items for a specific payout.

  The `:payout` filter (payout ID) is required.
  """
  @spec list(Client.t(), map(), keyword()) ::
          {:ok, %{items: [map()], meta: map()}}
          | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def list(%Client{} = client, params \\ %{}, opts \\ []) do
    Resource.list(client, @base_path, @resource_key, params, opts)
  end

  @doc "Returns a lazy `Stream` over all payout items for a payout."
  @spec stream(Client.t(), map(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.stream(client, @base_path, params, @resource_key, opts)
  end

  @doc "Eagerly collects all payout items into a list."
  @spec collect_all(Client.t(), map(), keyword()) ::
          {:ok, [map()]} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def collect_all(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.collect(client, @base_path, params, @resource_key, opts)
  end
end
