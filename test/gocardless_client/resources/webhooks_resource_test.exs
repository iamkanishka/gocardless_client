defmodule GoCardlessClient.Resources.WebhooksTest do
  use GoCardlessClient.TestCase

  alias GoCardlessClient.Resources.Webhooks
  alias Plug.Conn

  describe "list/3" do
    test "returns webhook delivery records", %{client: client, bypass: bypass} do
      records = build_list(2, :webhook_record)

      Bypass.expect_once(bypass, "GET", "/webhooks", fn conn ->
        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(200, Jason.encode!(%{
          "webhooks" => records,
          "meta" => %{"cursors" => %{"before" => nil, "after" => nil}}
        }))
      end)

      assert {:ok, %{items: items}} = Webhooks.list(client)
      assert length(items) == 2
    end
  end

  describe "retry/4" do
    test "POSTs to retry action", %{client: client, bypass: bypass} do
      record = build(:webhook_record)

      Bypass.expect_once(bypass, "POST", "/webhooks/WB123/actions/retry", fn conn ->
        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(200, Jason.encode!(%{"webhooks" => record}))
      end)

      assert {:ok, _} = Webhooks.retry(client, "WB123")
    end
  end
end
