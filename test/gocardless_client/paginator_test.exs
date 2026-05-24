defmodule GoCardlessClient.PaginatorTest do
  use GoCardlessClient.TestCase

  alias GoCardlessClient.Paginator
  alias Plug.Conn

  describe "stream/5" do
    test "is lazy and implements Enumerable", %{client: client} do
      stream = Paginator.stream(client, "/payments", %{}, "payments")
      assert Enumerable.impl_for(stream) != nil
    end
  end

  describe "collect/5 — single page" do
    test "returns all items when no next cursor", %{client: client, bypass: bypass} do
      payments = [%{"id" => "PM001"}, %{"id" => "PM002"}]

      Bypass.expect_once(bypass, "GET", "/payments", fn conn ->
        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(200, Jason.encode!(%{
          "payments" => payments,
          "meta" => %{"cursors" => %{"before" => nil, "after" => nil}}
        }))
      end)

      assert {:ok, items} = Paginator.collect(client, "/payments", %{}, "payments")
      assert length(items) == 2
      assert hd(items)["id"] == "PM001"
    end
  end

  describe "collect/5 — multi-page" do
    test "follows cursors across pages", %{client: client, bypass: bypass} do
      page1 = [%{"id" => "PM001"}, %{"id" => "PM002"}]
      page2 = [%{"id" => "PM003"}]

      # First call — return a cursor
      Bypass.expect(bypass, "GET", "/payments", fn conn ->
        params = URI.decode_query(conn.query_string)

        {items, after_cursor} =
          if params["after"] == "cursor_after_page1" do
            {page2, nil}
          else
            {page1, "cursor_after_page1"}
          end

        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(200, Jason.encode!(%{
          "payments" => items,
          "meta" => %{"cursors" => %{"before" => nil, "after" => after_cursor}}
        }))
      end)

      assert {:ok, all_items} = Paginator.collect(client, "/payments", %{}, "payments")
      assert length(all_items) == 3
      assert Enum.map(all_items, & &1["id"]) == ["PM001", "PM002", "PM003"]
    end
  end

  describe "collect/5 — error handling" do
    test "propagates API errors from first page", %{client: client, bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/payments", fn conn ->
        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(401, Jason.encode!(%{
          "error" => %{"type" => "invalid_api_usage", "code" => 401,
                       "message" => "Unauthorized", "errors" => []}
        }))
      end)

      assert {:error, error} = Paginator.collect(client, "/payments", %{}, "payments")
      assert error.code == 401
    end
  end
end
