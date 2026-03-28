defmodule GoCardlessClient.WebhooksTest do
  use ExUnit.Case, async: true

  alias GoCardlessClient.{Factory, Webhooks}

  @secret "test-webhook-secret"

  defp sign(payload, secret \\ @secret) do
    :crypto.mac(:hmac, :sha256, secret, payload)
    |> Base.encode16(case: :lower)
  end

  defp encode(map), do: Jason.encode!(map)

  # ── parse/3 ─────────────────────────────────────────────────────────────

  describe "parse/3" do
    test "returns parsed events for a valid payload and signature" do
      event = Factory.build(:event)
      payload = encode(%{"events" => [event]})
      sig = sign(payload)

      assert {:ok, [^event]} = Webhooks.parse(payload, sig, @secret)
    end

    test "returns :invalid_signature for a tampered payload" do
      payload = encode(%{"events" => []})
      assert {:error, :invalid_signature} = Webhooks.parse(payload, "bad_sig", @secret)
    end

    test "returns :invalid_signature when wrong secret is used" do
      payload = encode(%{"events" => []})
      sig = sign(payload, "wrong-secret")
      assert {:error, :invalid_signature} = Webhooks.parse(payload, sig, @secret)
    end

    test "returns :empty_payload for empty string" do
      assert {:error, :empty_payload} = Webhooks.parse("", "sig", @secret)
    end

    test "returns :empty_payload for nil body" do
      assert {:error, :empty_payload} = Webhooks.parse(nil, "sig", @secret)
    end

    test "returns :invalid_json for malformed JSON" do
      bad = "not-json"
      sig = sign(bad)
      assert {:error, :invalid_json} = Webhooks.parse(bad, sig, @secret)
    end

    test "parses multiple events in a single payload" do
      events = [
        Factory.build(:event, %{"resource_type" => "payments", "action" => "paid_out"}),
        Factory.build(:event, %{"resource_type" => "mandates", "action" => "active"}),
        Factory.build(:event, %{"resource_type" => "subscriptions", "action" => "cancelled"})
      ]

      payload = encode(%{"events" => events})
      sig = sign(payload)

      assert {:ok, parsed} = Webhooks.parse(payload, sig, @secret)
      assert length(parsed) == 3
    end

    test "handles an empty events array" do
      payload = encode(%{"events" => []})
      sig = sign(payload)

      assert {:ok, []} = Webhooks.parse(payload, sig, @secret)
    end
  end

  # ── verify/3 ────────────────────────────────────────────────────────────

  describe "verify/3" do
    test "returns :ok for a valid signature" do
      body = "test body"
      sig = sign(body)
      assert :ok = Webhooks.verify(body, sig, @secret)
    end

    test "returns :invalid_signature for bad signature" do
      assert {:error, :invalid_signature} = Webhooks.verify("body", "badsig", @secret)
    end
  end

  # ── Event type predicates ───────────────────────────────────────────────

  describe "event type helpers" do
    test "payment_event?/1" do
      assert Webhooks.payment_event?(%{"resource_type" => "payments"})
      refute Webhooks.payment_event?(%{"resource_type" => "mandates"})
    end

    test "mandate_event?/1" do
      assert Webhooks.mandate_event?(%{"resource_type" => "mandates"})
      refute Webhooks.mandate_event?(%{"resource_type" => "payments"})
    end

    test "subscription_event?/1" do
      assert Webhooks.subscription_event?(%{"resource_type" => "subscriptions"})
    end

    test "payout_event?/1" do
      assert Webhooks.payout_event?(%{"resource_type" => "payouts"})
    end

    test "refund_event?/1" do
      assert Webhooks.refund_event?(%{"resource_type" => "refunds"})
    end

    test "billing_request_event?/1" do
      assert Webhooks.billing_request_event?(%{"resource_type" => "billing_requests"})
    end

    test "action?/2" do
      assert Webhooks.action?(%{"action" => "paid_out"}, "paid_out")
      refute Webhooks.action?(%{"action" => "paid_out"}, "cancelled")
    end
  end

  # ── IP allowlist ─────────────────────────────────────────────────────────

  describe "gocardless_ip?/1" do
    test "returns false for non-GC IP" do
      refute Webhooks.gocardless_ip?("1.2.3.4")
    end

    test "returns false for invalid IP" do
      refute Webhooks.gocardless_ip?("not-an-ip")
    end

    test "returns true for a known GC range IP" do
      # 35.192.0.1 is within 35.192.0.0/14
      assert Webhooks.gocardless_ip?("35.192.0.1")
    end
  end

  # ── idempotency_key/0 ───────────────────────────────────────────────────

  describe "idempotency_key/0" do
    test "returns a 32-character hex string" do
      key = Webhooks.idempotency_key()
      assert String.length(key) == 32
      assert key =~ ~r/\A[0-9a-f]+\z/
    end

    test "returns a unique key each time" do
      keys = for _ <- 1..100, do: Webhooks.idempotency_key()
      assert length(Enum.uniq(keys)) == 100
    end
  end

  # ── Full event shape ─────────────────────────────────────────────────────

  describe "event structure" do
    test "payment.paid_out event has correct shape" do
      event = %{
        "id" => "EV001",
        "created_at" => "2024-01-15T10:00:00.000Z",
        "resource_type" => "payments",
        "action" => "paid_out",
        "details" => %{
          "origin" => "gocardless",
          "cause" => "payment_paid_out",
          "description" => "Payment paid out.",
          "will_attempt_retry" => false
        },
        "metadata" => %{},
        "links" => %{"payment" => "PM001", "payout" => "PO001"}
      }

      payload = encode(%{"events" => [event]})
      sig = sign(payload)

      assert {:ok, [parsed]} = Webhooks.parse(payload, sig, @secret)
      assert parsed["id"] == "EV001"
      assert parsed["resource_type"] == "payments"
      assert parsed["action"] == "paid_out"
      assert parsed["links"]["payment"] == "PM001"
      assert parsed["details"]["cause"] == "payment_paid_out"
    end

    test "mandate.failed event details" do
      event = %{
        "id" => "EV002",
        "created_at" => "2024-01-15T10:00:00.000Z",
        "resource_type" => "mandates",
        "action" => "failed",
        "details" => %{
          "origin" => "bank",
          "cause" => "bank_account_closed",
          "description" => "The bank account has been closed.",
          "reason_code" => "ARUDD-1",
          "scheme" => "bacs"
        },
        "metadata" => %{},
        "links" => %{"mandate" => "MD001"}
      }

      payload = encode(%{"events" => [event]})
      sig = sign(payload)

      assert {:ok, [parsed]} = Webhooks.parse(payload, sig, @secret)
      assert parsed["details"]["cause"] == "bank_account_closed"
      assert parsed["details"]["reason_code"] == "ARUDD-1"
    end
  end

  # ── All resource types ───────────────────────────────────────────────────

  @event_types [
    {"payments", "created"},
    {"payments", "submitted"},
    {"payments", "confirmed"},
    {"payments", "paid_out"},
    {"payments", "failed"},
    {"payments", "cancelled"},
    {"payments", "charged_back"},
    {"mandates", "created"},
    {"mandates", "active"},
    {"mandates", "cancelled"},
    {"mandates", "failed"},
    {"mandates", "expired"},
    {"mandates", "transferred"},
    {"subscriptions", "created"},
    {"subscriptions", "active"},
    {"subscriptions", "cancelled"},
    {"subscriptions", "finished"},
    {"payouts", "paid"},
    {"refunds", "created"},
    {"refunds", "paid"},
    {"billing_requests", "fulfilled"},
    {"billing_requests", "cancelled"}
  ]

  for {resource_type, action} <- @event_types do
    test "parses #{resource_type}.#{action} event" do
      event = %{
        "id" => "EV001",
        "created_at" => "2024-01-15T10:00:00.000Z",
        "resource_type" => unquote(resource_type),
        "action" => unquote(action),
        "details" => %{},
        "metadata" => %{},
        "links" => %{}
      }

      payload = Jason.encode!(%{"events" => [event]})
      sig = :crypto.mac(:hmac, :sha256, @secret, payload) |> Base.encode16(case: :lower)

      assert {:ok, [parsed]} = Webhooks.parse(payload, sig, @secret)
      assert parsed["resource_type"] == unquote(resource_type)
      assert parsed["action"] == unquote(action)
    end
  end
end
