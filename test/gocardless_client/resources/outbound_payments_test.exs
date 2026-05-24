defmodule GoCardlessClient.Resources.OutboundPaymentsTest do
  use GoCardlessClient.TestCase

  alias GoCardlessClient.Resources.OutboundPayments
  alias Plug.Conn

  describe "create/3" do
    test "POSTs to /outbound_payments", %{client: client, bypass: bypass} do
      payment = build(:outbound_payment)

      Bypass.expect_once(bypass, "POST", "/outbound_payments", fn conn ->
        {:ok, body, conn} = Conn.read_body(conn)
        assert Map.has_key?(Jason.decode!(body), "outbound_payments")

        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(201, Jason.encode!(%{"outbound_payments" => payment}))
      end)

      assert {:ok, result} =
               OutboundPayments.create(client, %{
                 amount: 5000,
                 currency: "GBP",
                 links: %{payment_account: "PA123"}
               })

      assert result["amount"] == 5000
    end
  end

  describe "withdrawal/3" do
    test "POSTs to /outbound_payments/withdrawal", %{client: client, bypass: bypass} do
      payment = build(:outbound_payment)

      Bypass.expect_once(bypass, "POST", "/outbound_payments/withdrawal", fn conn ->
        {:ok, body, conn} = Conn.read_body(conn)
        parsed = Jason.decode!(body)
        assert Map.has_key?(parsed, "outbound_payments")

        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(201, Jason.encode!(%{"outbound_payments" => payment}))
      end)

      assert {:ok, _} =
               OutboundPayments.withdrawal(client, %{
                 amount: 100_000,
                 currency: "GBP",
                 links: %{payment_account: "PA123", creditor_bank_account: "BA456"}
               })
    end
  end

  describe "statistics/2" do
    test "GETs /outbound_payments/statistics", %{client: client, bypass: bypass} do
      stats = %{"total" => 10, "total_amount" => 500_000}

      Bypass.expect_once(bypass, "GET", "/outbound_payments/statistics", fn conn ->
        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(200, Jason.encode!(stats))
      end)

      assert {:ok, result} = OutboundPayments.statistics(client)
      assert result["total"] == 10
    end
  end

  describe "cancel/4 and approve/4" do
    test "cancel POSTs to action endpoint", %{client: client, bypass: bypass} do
      payment = build(:outbound_payment, %{"status" => "cancelled"})

      Bypass.expect_once(bypass, "POST", "/outbound_payments/OP123/actions/cancel", fn conn ->
        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(200, Jason.encode!(%{"outbound_payments" => payment}))
      end)

      assert {:ok, _} = OutboundPayments.cancel(client, "OP123")
    end

    test "approve POSTs to action endpoint", %{client: client, bypass: bypass} do
      payment = build(:outbound_payment, %{"status" => "executing"})

      Bypass.expect_once(bypass, "POST", "/outbound_payments/OP123/actions/approve", fn conn ->
        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(200, Jason.encode!(%{"outbound_payments" => payment}))
      end)

      assert {:ok, _} = OutboundPayments.approve(client, "OP123")
    end
  end
end
