defmodule GoCardlessClient.Resources.EventsTest do
  use GoCardlessClient.TestCase

  alias GoCardlessClient.Resources.Events
  alias Plug.Conn

  describe "list/3" do
    test "returns events with filters", %{client: client, bypass: bypass} do
      events = build_list(3, :event)

      Bypass.expect_once(bypass, "GET", "/events", fn conn ->
        params = URI.decode_query(conn.query_string)
        assert params["resource_type"] == "payments"

        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(200, Jason.encode!(%{
          "events" => events,
          "meta" => %{"cursors" => %{"before" => nil, "after" => nil}}
        }))
      end)

      assert {:ok, %{items: items}} = Events.list(client, %{resource_type: "payments"})
      assert length(items) == 3
    end
  end

  describe "get/3" do
    test "returns single event", %{client: client, bypass: bypass} do
      event = build(:event, %{"id" => "EV123"})

      Bypass.expect_once(bypass, "GET", "/events/EV123", fn conn ->
        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(200, Jason.encode!(%{"events" => event}))
      end)

      assert {:ok, result} = Events.get(client, "EV123")
      assert result["id"] == "EV123"
    end
  end
end
