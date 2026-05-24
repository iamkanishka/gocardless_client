defmodule GoCardlessClient.Resources.MandatesTest do
  use GoCardlessClient.TestCase

  alias GoCardlessClient.Resources.Mandates
  alias Plug.Conn

  describe "create/3" do
    test "creates mandate with correct body", %{client: client, bypass: bypass} do
      mandate = build(:mandate)

      Bypass.expect_once(bypass, "POST", "/mandates", fn conn ->
        {:ok, body, conn} = Conn.read_body(conn)
        assert Map.has_key?(Jason.decode!(body), "mandates")

        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(201, Jason.encode!(%{"mandates" => mandate}))
      end)

      assert {:ok, result} =
               Mandates.create(client, %{
                 links: %{customer_bank_account: "BA123"}
               })

      assert result["status"] == "active"
    end
  end

  describe "cancel/4" do
    test "POSTs to cancel action", %{client: client, bypass: bypass} do
      mandate = build(:mandate, %{"status" => "cancelled"})

      Bypass.expect_once(bypass, "POST", "/mandates/MD123/actions/cancel", fn conn ->
        {:ok, body, conn} = Conn.read_body(conn)
        parsed = Jason.decode!(body)
        assert Map.has_key?(parsed, "mandates"), "action body must be wrapped in resource key"

        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(200, Jason.encode!(%{"mandates" => mandate}))
      end)

      assert {:ok, result} = Mandates.cancel(client, "MD123")
      assert result["status"] == "cancelled"
    end
  end

  describe "reinstate/4" do
    test "POSTs to reinstate action", %{client: client, bypass: bypass} do
      mandate = build(:mandate, %{"status" => "active"})

      Bypass.expect_once(bypass, "POST", "/mandates/MD123/actions/reinstate", fn conn ->
        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(200, Jason.encode!(%{"mandates" => mandate}))
      end)

      assert {:ok, result} = Mandates.reinstate(client, "MD123")
      assert result["status"] == "active"
    end
  end
end
