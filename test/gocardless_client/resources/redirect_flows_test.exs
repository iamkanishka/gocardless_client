defmodule GoCardlessClient.Resources.RedirectFlowsTest do
  use GoCardlessClient.TestCase

  alias GoCardlessClient.Resources.RedirectFlows
  alias Plug.Conn

  describe "create/3" do
    test "creates redirect flow", %{client: client, bypass: bypass} do
      flow = build(:redirect_flow)

      Bypass.expect_once(bypass, "POST", "/redirect_flows", fn conn ->
        {:ok, body, conn} = Conn.read_body(conn)
        assert Map.has_key?(Jason.decode!(body), "redirect_flows")

        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(201, Jason.encode!(%{"redirect_flows" => flow}))
      end)

      assert {:ok, result} = RedirectFlows.create(client, %{
        description: "Set up your Direct Debit",
        session_token: "sess_123",
        success_redirect_url: "https://myapp.com/done"
      })
      assert result["session_token"] == "sess_123"
    end
  end

  describe "complete/4" do
    test "POSTs to /redirect_flows/:id/actions/complete", %{client: client, bypass: bypass} do
      flow = build(:redirect_flow)

      Bypass.expect_once(bypass, "POST", "/redirect_flows/RE123/actions/complete", fn conn ->
        {:ok, body, conn} = Conn.read_body(conn)
        parsed = Jason.decode!(body)
        assert parsed["redirect_flows"]["session_token"] == "sess_123"

        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(200, Jason.encode!(%{"redirect_flows" => flow}))
      end)

      assert {:ok, _} = RedirectFlows.complete(client, "RE123", %{session_token: "sess_123"})
    end
  end

  describe "list/3" do
    test "lists redirect flows", %{client: client, bypass: bypass} do
      flows = build_list(2, :redirect_flow)

      Bypass.expect_once(bypass, "GET", "/redirect_flows", fn conn ->
        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(200, Jason.encode!(%{
          "redirect_flows" => flows,
          "meta" => %{"cursors" => %{"before" => nil, "after" => nil}}
        }))
      end)

      assert {:ok, %{items: items}} = RedirectFlows.list(client)
      assert length(items) == 2
    end
  end
end
