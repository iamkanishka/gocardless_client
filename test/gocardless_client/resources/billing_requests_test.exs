defmodule GoCardlessClient.Resources.BillingRequestsTest do
  use GoCardlessClient.TestCase

  alias GoCardlessClient.Resources.BillingRequests
  alias Plug.Conn

  describe "create/3" do
    test "creates billing request", %{client: client, bypass: bypass} do
      br = build(:billing_request)

      Bypass.expect_once(bypass, "POST", "/billing_requests", fn conn ->
        {:ok, body, conn} = Conn.read_body(conn)
        assert Map.has_key?(Jason.decode!(body), "billing_requests")

        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(201, Jason.encode!(%{"billing_requests" => br}))
      end)

      assert {:ok, result} =
               BillingRequests.create(client, %{
                 mandate_request: %{currency: "GBP"}
               })

      assert result["status"] == "pending"
    end
  end

  describe "action endpoints" do
    for action <- ~w(fulfil cancel notify fallback) do
      test "#{action} wraps body in billing_requests key", %{client: client, bypass: bypass} do
        br = build(:billing_request)
        action = unquote(action)

        Bypass.expect_once(
          bypass,
          "POST",
          "/billing_requests/BRQ123/actions/#{action}",
          fn conn ->
            {:ok, body, conn} = Conn.read_body(conn)
            parsed = Jason.decode!(body)

            assert Map.has_key?(parsed, "billing_requests"),
                   "action '#{action}' body must be wrapped in 'billing_requests' key, got: #{inspect(Map.keys(parsed))}"

            conn
            |> Conn.put_resp_content_type("application/json")
            |> Conn.send_resp(200, Jason.encode!(%{"billing_requests" => br}))
          end
        )

        func = String.to_existing_atom(action)
        assert {:ok, _} = apply(BillingRequests, func, [client, "BRQ123", %{}])
      end
    end
  end

  describe "select_institution/4" do
    test "POSTs to select_institution action", %{client: client, bypass: bypass} do
      br = build(:billing_request)

      Bypass.expect_once(
        bypass,
        "POST",
        "/billing_requests/BRQ123/actions/select_institution",
        fn conn ->
          {:ok, body, conn} = Conn.read_body(conn)
          parsed = Jason.decode!(body)
          assert parsed["billing_requests"]["institution"] == "MONZO"

          conn
          |> Conn.put_resp_content_type("application/json")
          |> Conn.send_resp(200, Jason.encode!(%{"billing_requests" => br}))
        end
      )

      assert {:ok, _} =
               BillingRequests.select_institution(client, "BRQ123", %{
                 institution: "MONZO",
                 country_code: "GB"
               })
    end
  end
end
