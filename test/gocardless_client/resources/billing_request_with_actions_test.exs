defmodule GoCardlessClient.Resources.BillingRequestWithActionsTest do
  use GoCardlessClient.TestCase

  alias GoCardlessClient.Resources.BillingRequestWithActions
  alias Plug.Conn

  describe "create/3" do
    test "POSTs to /billing_requests_with_actions", %{client: client, bypass: bypass} do
      br = build(:billing_request, %{"status" => "fulfilled"})

      Bypass.expect_once(bypass, "POST", "/billing_requests_with_actions", fn conn ->
        {:ok, body, conn} = Conn.read_body(conn)
        parsed = Jason.decode!(body)
        assert Map.has_key?(parsed, "billing_requests")
        assert is_list(parsed["billing_requests"]["actions"])

        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(201, Jason.encode!(%{"billing_requests" => br}))
      end)

      assert {:ok, result} = BillingRequestWithActions.create(client, %{
        mandate_request: %{currency: "GBP"},
        actions: [
          %{
            type: "collect_customer_details",
            collect_customer_details: %{
              customer: %{given_name: "Alice", family_name: "Smith", email: "alice@example.com"}
            }
          },
          %{type: "confirm_payer_details", confirm_payer_details: %{}},
          %{type: "fulfil", fulfil: %{}}
        ]
      })
      assert result["status"] == "fulfilled"
    end
  end
end
