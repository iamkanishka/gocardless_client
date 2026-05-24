defmodule GoCardlessClient.Webhooks do
  @moduledoc """
  Webhook signature verification, event parsing, and helper predicates.

  Use this module in your web server to securely receive and process GoCardless
  webhook events. For the webhook delivery log API, see
  `GoCardlessClient.Resources.Webhooks`.

  ## Security

  Always verify the `Webhook-Signature` header before processing any event.
  GoCardless signs each request with your webhook secret using HMAC-SHA256.
  This prevents attackers from sending forged webhook events.

  ## Example (Phoenix controller)

      def webhook(conn, _params) do
        secret = Application.fetch_env!(:my_app, :gocardless_webhook_secret)
        raw_body = conn.assigns[:raw_body]
        signature = get_req_header(conn, "webhook-signature") |> List.first()

        case GoCardlessClient.Webhooks.parse(raw_body, signature, secret) do
          {:ok, events} ->
            Enum.each(events, &dispatch_event/1)
            send_resp(conn, 200, "OK")

          {:error, :invalid_signature} ->
            send_resp(conn, 498, "Invalid signature")

          {:error, reason} ->
            send_resp(conn, 400, "Bad request: \#{reason}")
        end
      end

  ## Generating idempotency keys

      key = GoCardlessClient.Webhooks.idempotency_key()

  ## Known GoCardless IP ranges

  Use `gocardless_ip?/1` to validate the request origin as an additional
  (not primary) security measure. Always prefer signature verification.
  """

  @max_payload_bytes 10 * 1024 * 1024

  # GoCardless outbound IP CIDR ranges (current as of 2024)
  @gc_cidrs [
    "35.192.0.0/14",
    "35.196.0.0/14",
    "35.200.0.0/13",
    "35.208.0.0/12",
    "35.224.0.0/12",
    "35.240.0.0/13",
    "104.196.0.0/14",
    "104.155.0.0/16",
    "104.154.0.0/15",
    "146.148.0.0/17",
    "146.148.128.0/17",
    "104.196.128.0/18",
    "34.86.0.0/15",
    "34.100.0.0/16",
    "34.102.0.0/15",
    "34.104.0.0/14"
  ]

  import Bitwise, only: [band: 2, bsl: 2, bsr: 2]

  # ── Public API ────────────────────────────────────────────────────────────

  @doc """
  Parses and verifies a webhook payload.

  Returns `{:ok, [event]}` on success, or `{:error, reason}` on failure.

  Possible errors:
  - `:empty_payload` — body is nil or empty string
  - `:payload_too_large` — body exceeds 10MB
  - `:invalid_signature` — signature does not match
  - `:invalid_json` — body is not valid JSON
  """
  @spec parse(String.t() | nil, String.t() | nil, String.t()) ::
          {:ok, [map()]} | {:error, atom()}
  def parse(body, signature, secret) do
    with :ok <- validate_body(body),
         :ok <- verify(body, signature, secret) do
      decode_events(body)
    end
  end

  @doc """
  Verifies a webhook signature using HMAC-SHA256.

  Returns `:ok` or `{:error, :invalid_signature}`.
  Uses constant-time comparison to prevent timing attacks.
  """
  @spec verify(String.t(), String.t() | nil, String.t()) :: :ok | {:error, :invalid_signature}
  def verify(body, signature, secret) when is_binary(body) and is_binary(signature) do
    expected = :crypto.mac(:hmac, :sha256, secret, body) |> Base.encode16(case: :lower)

    if Plug.Crypto.secure_compare(expected, String.downcase(signature)) do
      :ok
    else
      {:error, :invalid_signature}
    end
  end

  def verify(_, _, _), do: {:error, :invalid_signature}

  @doc """
  Returns `true` if the IP address is within GoCardless's known outbound ranges.

  Use as an additional (not primary) security check. Signature verification
  with `verify/3` should always be your primary security measure.
  """
  @spec gocardless_ip?(String.t()) :: boolean()
  def gocardless_ip?(ip) when is_binary(ip) do
    case :inet.parse_address(String.to_charlist(ip)) do
      {:ok, addr} -> Enum.any?(@gc_cidrs, &ip_in_cidr?(addr, &1))
      {:error, _} -> false
    end
  end

  def gocardless_ip?(_), do: false

  @doc """
  Generates a cryptographically random idempotency key.

  Returns a 32-character lowercase hex string (128 bits of entropy).
  Use this when creating payments, billing requests, or any write operation.

      opts = [idempotency_key: GoCardlessClient.Webhooks.idempotency_key()]
  """
  @spec idempotency_key() :: String.t()
  def idempotency_key do
    :crypto.strong_rand_bytes(16) |> Base.encode16(case: :lower)
  end

  # ── Event type predicates ─────────────────────────────────────────────────

  @doc "Returns `true` if the event is for a payment resource."
  @spec payment_event?(map()) :: boolean()
  def payment_event?(%{"resource_type" => "payments"}), do: true
  def payment_event?(_), do: false

  @doc "Returns `true` if the event is for a mandate resource."
  @spec mandate_event?(map()) :: boolean()
  def mandate_event?(%{"resource_type" => "mandates"}), do: true
  def mandate_event?(_), do: false

  @doc "Returns `true` if the event is for a subscription resource."
  @spec subscription_event?(map()) :: boolean()
  def subscription_event?(%{"resource_type" => "subscriptions"}), do: true
  def subscription_event?(_), do: false

  @doc "Returns `true` if the event is for a payout resource."
  @spec payout_event?(map()) :: boolean()
  def payout_event?(%{"resource_type" => "payouts"}), do: true
  def payout_event?(_), do: false

  @doc "Returns `true` if the event is for a refund resource."
  @spec refund_event?(map()) :: boolean()
  def refund_event?(%{"resource_type" => "refunds"}), do: true
  def refund_event?(_), do: false

  @doc "Returns `true` if the event is for a billing request resource."
  @spec billing_request_event?(map()) :: boolean()
  def billing_request_event?(%{"resource_type" => "billing_requests"}), do: true
  def billing_request_event?(_), do: false

  @doc "Returns `true` if the event is for an instalment schedule resource."
  @spec instalment_schedule_event?(map()) :: boolean()
  def instalment_schedule_event?(%{"resource_type" => "instalment_schedules"}), do: true
  def instalment_schedule_event?(_), do: false

  @doc "Returns `true` if the event is for an outbound payment resource."
  @spec outbound_payment_event?(map()) :: boolean()
  def outbound_payment_event?(%{"resource_type" => "outbound_payments"}), do: true
  def outbound_payment_event?(_), do: false

  @doc "Returns `true` if the event is for a creditor resource."
  @spec creditor_event?(map()) :: boolean()
  def creditor_event?(%{"resource_type" => "creditors"}), do: true
  def creditor_event?(_), do: false

  @doc "Returns `true` if the event is for a customer resource."
  @spec customer_event?(map()) :: boolean()
  def customer_event?(%{"resource_type" => "customers"}), do: true
  def customer_event?(_), do: false

  @doc "Returns `true` if the event is for an export resource."
  @spec export_event?(map()) :: boolean()
  def export_event?(%{"resource_type" => "exports"}), do: true
  def export_event?(_), do: false

  @doc "Returns `true` if the event is for a payment account transaction resource."
  @spec payment_account_transaction_event?(map()) :: boolean()
  def payment_account_transaction_event?(%{"resource_type" => "payment_account_transactions"}),
    do: true

  def payment_account_transaction_event?(_), do: false

  @doc "Returns `true` if the event is for a scheme identifier resource."
  @spec scheme_identifier_event?(map()) :: boolean()
  def scheme_identifier_event?(%{"resource_type" => "scheme_identifiers"}), do: true
  def scheme_identifier_event?(_), do: false

  @doc """
  Returns `true` if the event has the given action string.

      iex> GoCardlessClient.Webhooks.action?(%{"action" => "paid_out"}, "paid_out")
      true
  """
  @spec action?(map(), String.t()) :: boolean()
  def action?(%{"action" => action}, expected), do: action == expected
  def action?(_, _), do: false

  # ── Private helpers ───────────────────────────────────────────────────────

  defp validate_body(nil), do: {:error, :empty_payload}
  defp validate_body(""), do: {:error, :empty_payload}

  defp validate_body(body) when is_binary(body) do
    if byte_size(body) > @max_payload_bytes do
      {:error, :payload_too_large}
    else
      :ok
    end
  end

  defp decode_events(body) do
    case Jason.decode(body) do
      {:ok, %{"events" => events}} when is_list(events) -> {:ok, events}
      {:ok, _} -> {:ok, []}
      {:error, _} -> {:error, :invalid_json}
    end
  end

  defp ip_in_cidr?(addr, cidr) do
    [network_str, prefix_len_str] = String.split(cidr, "/")
    prefix_len = String.to_integer(prefix_len_str)
    {:ok, network} = :inet.parse_address(String.to_charlist(network_str))

    mask_bits = ones_mask(prefix_len)
    band(ip_to_int(addr), mask_bits) == band(ip_to_int(network), mask_bits)
  end

  defp ip_to_int({a, b, c, d}), do: a * 16_777_216 + b * 65_536 + c * 256 + d
  defp ones_mask(n), do: bsl(1, 32) - bsr(1, n - 32)
end
