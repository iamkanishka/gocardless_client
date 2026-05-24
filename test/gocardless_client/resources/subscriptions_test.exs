defmodule GoCardlessClient.Resources.SubscriptionsTest do
  use GoCardlessClient.TestCase

  alias GoCardlessClient.Resources.Subscriptions
  alias Plug.Conn

  describe "create/3" do
    test "creates subscription", %{client: client, bypass: bypass} do
      sub = build(:subscription)

      Bypass.expect_once(bypass, "POST", "/subscriptions", fn conn ->
        {:ok, body, conn} = Conn.read_body(conn)
        assert Map.has_key?(Jason.decode!(body), "subscriptions")

        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(201, Jason.encode!(%{"subscriptions" => sub}))
      end)

      assert {:ok, result} =
               Subscriptions.create(client, %{
                 amount: 2500,
                 currency: "GBP",
                 interval_unit: "monthly",
                 interval: 1,
                 links: %{mandate: "MD123"}
               })

      assert result["amount"] == 2500
    end
  end

  describe "pause/4" do
    test "POSTs to pause action with billing_requests key", %{client: client, bypass: bypass} do
      sub = build(:subscription, %{"status" => "paused"})

      Bypass.expect_once(bypass, "POST", "/subscriptions/SB123/actions/pause", fn conn ->
        {:ok, body, conn} = Conn.read_body(conn)
        parsed = Jason.decode!(body)
        assert Map.has_key?(parsed, "subscriptions")

        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(200, Jason.encode!(%{"subscriptions" => sub}))
      end)

      assert {:ok, result} = Subscriptions.pause(client, "SB123")
      assert result["status"] == "paused"
    end
  end

  describe "resume/4 and cancel/4" do
    test "resume POSTs to action", %{client: client, bypass: bypass} do
      sub = build(:subscription, %{"status" => "active"})

      Bypass.expect_once(bypass, "POST", "/subscriptions/SB123/actions/resume", fn conn ->
        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(200, Jason.encode!(%{"subscriptions" => sub}))
      end)

      assert {:ok, _} = Subscriptions.resume(client, "SB123")
    end

    test "cancel POSTs to action", %{client: client, bypass: bypass} do
      sub = build(:subscription, %{"status" => "cancelled"})

      Bypass.expect_once(bypass, "POST", "/subscriptions/SB123/actions/cancel", fn conn ->
        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(200, Jason.encode!(%{"subscriptions" => sub}))
      end)

      assert {:ok, _} = Subscriptions.cancel(client, "SB123")
    end
  end
end
