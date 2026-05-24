defmodule GoCardlessClient.Resources.ScenarioSimulators do
  @moduledoc """
  GoCardless Scenario Simulators API — **Sandbox only**.

  Simulate specific payment lifecycle outcomes for testing without needing real
  bank interactions. Use these to build and verify your webhook handlers and
  reconciliation logic before going live.

  ## Available scenarios

  ### Payment scenarios
  - `"payment_paid_out"` — payment moves to paid_out
  - `"payment_failed"` — payment fails
  - `"payment_charged_back"` — payment is charged back
  - `"payment_late_failure"` — payment fails late (after confirmation)
  - `"payment_customer_approval_granted"` — customer approves payment
  - `"payment_customer_approval_denied"` — customer denies payment

  ### Mandate scenarios
  - `"mandate_activated"` — mandate becomes active
  - `"mandate_customer_approval_granted"` — customer approves mandate
  - `"mandate_customer_approval_skipped"` — approval step skipped
  - `"mandate_failed"` — mandate fails
  - `"mandate_cancelled"` — mandate is cancelled
  - `"mandate_transferred"` — mandate transferred to new bank account
  - `"mandate_expired"` — mandate expires

  ### Payout scenarios
  - `"payout_paid"` — payout is marked as paid

  ### Refund scenarios
  - `"refund_paid"` — refund is paid to customer

  ### Billing request scenarios
  - `"billing_request_fulfilled"` — billing request is fulfilled
  - `"billing_request_bank_authorisation_authorised"` — bank auth completed
  - `"billing_request_bank_authorisation_denied"` — bank auth denied
  - `"billing_request_bank_authorisation_expired"` — bank auth expired

  ## Example

      # Simulate a payment being paid out
      {:ok, _} = GoCardlessClient.Resources.ScenarioSimulators.run(
        client,
        "payment_paid_out",
        %{links: %{payment: "PM123"}}
      )

      # Simulate a mandate failure
      {:ok, _} = GoCardlessClient.Resources.ScenarioSimulators.run(
        client,
        "mandate_failed",
        %{links: %{mandate: "MD456"}}
      )
  """

  alias GoCardlessClient.{Client, HTTP}

  @valid_scenarios ~w(
    payment_paid_out
    payment_failed
    payment_charged_back
    payment_late_failure
    payment_customer_approval_granted
    payment_customer_approval_denied
    mandate_activated
    mandate_customer_approval_granted
    mandate_customer_approval_skipped
    mandate_failed
    mandate_cancelled
    mandate_transferred
    mandate_expired
    payout_paid
    refund_paid
    billing_request_fulfilled
    billing_request_bank_authorisation_authorised
    billing_request_bank_authorisation_denied
    billing_request_bank_authorisation_expired
  )

  @base_path "/scenario_simulators"
  @resource_key "scenario_simulators"

  @doc """
  Runs a scenario simulation against a specific resource.

  ## Params

  Supply exactly one link matching the scenario type:

  - `links.payment` — for payment scenarios
  - `links.mandate` — for mandate scenarios
  - `links.payout` — for payout scenarios
  - `links.refund` — for refund scenarios
  - `links.billing_request` — for billing request scenarios
  - `links.subscription` — for subscription scenarios
  - `links.instalment_schedule` — for instalment schedule scenarios

  ## Raises

  Raises `ArgumentError` if an unknown scenario type is provided.
  """
  @spec run(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map() | nil} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def run(%Client{} = client, scenario_type, params \\ %{}, opts \\ []) do
    unless scenario_type in @valid_scenarios do
      raise ArgumentError,
            "Unknown scenario type: #{inspect(scenario_type)}. " <>
              "Valid types: #{Enum.join(@valid_scenarios, ", ")}"
    end

    path = "#{@base_path}/#{scenario_type}/actions/run"
    opts = Keyword.put(opts, :body, %{@resource_key => params})

    case HTTP.Client.request(client.config, :post, path, opts) do
      {:ok, body} -> {:ok, unwrap(body)}
      err -> err
    end
  end

  @doc "Returns a list of all valid scenario type strings."
  @spec valid_scenarios() :: [String.t()]
  def valid_scenarios, do: @valid_scenarios

  defp unwrap(nil), do: nil
  defp unwrap(body) when is_map(body), do: Map.get(body, @resource_key, body)
  defp unwrap(body), do: body
end
