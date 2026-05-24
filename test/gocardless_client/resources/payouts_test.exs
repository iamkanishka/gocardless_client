defmodule GoCardlessClient.Resources.PayoutsTest do
  use GoCardlessClient.TestCase

  alias GoCardlessClient.Resources.{PayoutItems, Payouts}
  alias Plug.Conn

  describe "Payouts.list/3" do
    test "returns payouts", %{client: client, bypass: bypass} do
      payouts = build_list(2, :payout)

      Bypass.expect_once(bypass, "GET", "/payouts", fn conn ->
        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(
          200,
          Jason.encode!(%{
            "payouts" => payouts,
            "meta" => %{"cursors" => %{"before" => nil, "after" => nil}}
          })
        )
      end)

      assert {:ok, %{items: items}} = Payouts.list(client, %{status: "paid"})
      assert length(items) == 2
    end
  end

  describe "Payouts.update/4" do
    test "POSTs (not PUT) to update metadata", %{client: client, bypass: bypass} do
      payout = build(:payout)

      Bypass.expect_once(bypass, "POST", "/payouts/PO123", fn conn ->
        {:ok, body, conn} = Conn.read_body(conn)
        assert Map.has_key?(Jason.decode!(body), "payouts")

        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(200, Jason.encode!(%{"payouts" => payout}))
      end)

      assert {:ok, _} = Payouts.update(client, "PO123", %{metadata: %{ref: "Q1-2025"}})
    end
  end

  describe "PayoutItems.list/3" do
    test "returns payout line items", %{client: client, bypass: bypass} do
      items = build_list(5, :payout_item)

      Bypass.expect_once(bypass, "GET", "/payout_items", fn conn ->
        params = URI.decode_query(conn.query_string)
        assert params["payout"] == "PO123"

        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(
          200,
          Jason.encode!(%{
            "payout_items" => items,
            "meta" => %{"cursors" => %{"before" => nil, "after" => nil}}
          })
        )
      end)

      assert {:ok, %{items: result_items}} = PayoutItems.list(client, %{payout: "PO123"})
      assert length(result_items) == 5
      assert hd(result_items)["type"] == "payment_paid_out"
    end
  end
end
