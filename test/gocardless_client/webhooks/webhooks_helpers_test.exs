defmodule GoCardlessClient.WebhooksHelpersTest do
  use ExUnit.Case, async: true

  alias GoCardlessClient.Webhooks

  describe "new event type helpers" do
    test "instalment_schedule_event?/1" do
      assert Webhooks.instalment_schedule_event?(%{"resource_type" => "instalment_schedules"})
      refute Webhooks.instalment_schedule_event?(%{"resource_type" => "payments"})
    end

    test "outbound_payment_event?/1" do
      assert Webhooks.outbound_payment_event?(%{"resource_type" => "outbound_payments"})
      refute Webhooks.outbound_payment_event?(%{"resource_type" => "payments"})
    end

    test "creditor_event?/1" do
      assert Webhooks.creditor_event?(%{"resource_type" => "creditors"})
    end

    test "customer_event?/1" do
      assert Webhooks.customer_event?(%{"resource_type" => "customers"})
    end

    test "export_event?/1" do
      assert Webhooks.export_event?(%{"resource_type" => "exports"})
    end

    test "payment_account_transaction_event?/1" do
      assert Webhooks.payment_account_transaction_event?(%{
        "resource_type" => "payment_account_transactions"
      })
    end

    test "scheme_identifier_event?/1" do
      assert Webhooks.scheme_identifier_event?(%{"resource_type" => "scheme_identifiers"})
    end
  end

  describe "payload_too_large guard" do
    test "returns :payload_too_large for oversized body" do
      # 10MB + 1 byte
      huge_body = String.duplicate("x", 10 * 1024 * 1024 + 1)
      assert {:error, :payload_too_large} = Webhooks.parse(huge_body, "sig", "secret")
    end
  end
end
