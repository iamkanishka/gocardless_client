defmodule GoCardlessClient.Resources.PaymentsTest do
  use GoCardlessClient.TestCase

  alias GoCardlessClient.Resources.Payments
  alias Plug.Conn

  describe "create/3" do
    test "POSTs to /payments wrapped in resource key", %{client: client, bypass: bypass} do
      payment = build(:payment)

      Bypass.expect_once(bypass, "POST", "/payments", fn conn ->
        {:ok, body, conn} = Conn.read_body(conn)
        parsed = Jason.decode!(body)
        assert Map.has_key?(parsed, "payments")
        assert parsed["payments"]["amount"] == 1500

        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(201, Jason.encode!(%{"payments" => payment}))
      end)

      assert {:ok, result} = Payments.create(client, %{
        amount: 1500, currency: "GBP", links: %{mandate: "MD123"}
      })
      assert result["amount"] == 1500
    end
  end

  describe "cancel/4" do
    test "POSTs to /payments/:id/actions/cancel", %{client: client, bypass: bypass} do
      payment = build(:payment, %{"status" => "cancelled"})

      Bypass.expect_once(bypass, "POST", "/payments/PM123/actions/cancel", fn conn ->
        {:ok, body, conn} = Conn.read_body(conn)
        parsed = Jason.decode!(body)
        # action body must be wrapped in resource key, NOT "data"
        assert Map.has_key?(parsed, "payments"), "action body must use resource key 'payments'"

        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(200, Jason.encode!(%{"payments" => payment}))
      end)

      assert {:ok, result} = Payments.cancel(client, "PM123")
      assert result["status"] == "cancelled"
    end
  end

  describe "retry/4" do
    test "POSTs to /payments/:id/actions/retry", %{client: client, bypass: bypass} do
      payment = build(:payment, %{"status" => "pending_submission"})

      Bypass.expect_once(bypass, "POST", "/payments/PM123/actions/retry", fn conn ->
        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(200, Jason.encode!(%{"payments" => payment}))
      end)

      assert {:ok, result} = Payments.retry(client, "PM123", %{charge_date: "2025-03-01"})
      assert result["status"] == "pending_submission"
    end
  end

  describe "list/3" do
    test "returns paginated results", %{client: client, bypass: bypass} do
      payments = build_list(2, :payment)

      Bypass.expect_once(bypass, "GET", "/payments", fn conn ->
        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(200, Jason.encode!(%{
          "payments" => payments,
          "meta" => %{"cursors" => %{"before" => nil, "after" => "cursor_abc"}}
        }))
      end)

      assert {:ok, %{items: items, meta: meta}} = Payments.list(client, %{mandate: "MD123"})
      assert length(items) == 2
      assert meta["cursors"]["after"] == "cursor_abc"
    end
  end

  describe "update/4" do
    test "POSTs (not PUT) to update endpoint", %{client: client, bypass: bypass} do
      payment = build(:payment)

      Bypass.expect_once(bypass, "POST", "/payments/PM123", fn conn ->
        {:ok, body, conn} = Conn.read_body(conn)
        parsed = Jason.decode!(body)
        assert Map.has_key?(parsed, "payments")

        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(200, Jason.encode!(%{"payments" => payment}))
      end)

      assert {:ok, _} = Payments.update(client, "PM123", %{metadata: %{ref: "INV-001"}})
    end
  end
end
