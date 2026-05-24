defmodule GoCardlessClient.Resources.BlocksTest do
  use GoCardlessClient.TestCase

  alias GoCardlessClient.Resources.Blocks
  alias Plug.Conn

  describe "create/3" do
    test "creates a block", %{client: client, bypass: bypass} do
      block = build(:block)

      Bypass.expect_once(bypass, "POST", "/blocks", fn conn ->
        {:ok, body, conn} = Conn.read_body(conn)
        parsed = Jason.decode!(body)
        assert parsed["blocks"]["block_type"] == "email"

        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(201, Jason.encode!(%{"blocks" => block}))
      end)

      assert {:ok, result} = Blocks.create(client, %{
        block_type: "email",
        reason_type: "fraud",
        resource_reference: "fraudster@example.com"
      })
      assert result["block_type"] == "email"
    end
  end

  describe "block_by_reference/3" do
    test "POSTs to /blocks/block_by_reference", %{client: client, bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/blocks/block_by_reference", fn conn ->
        {:ok, body, conn} = Conn.read_body(conn)
        parsed = Jason.decode!(body)
        assert parsed["blocks"]["reference_type"] == "mandate"

        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(200, Jason.encode!(%{"blocks" => %{}}))
      end)

      assert {:ok, _} = Blocks.block_by_reference(client, %{
        reference_type: "mandate",
        reference_id: "MD123",
        reason_type: "fraud"
      })
    end
  end

  describe "enable/4 and disable/4" do
    test "disable POSTs to action", %{client: client, bypass: bypass} do
      block = build(:block, %{"active" => false})

      Bypass.expect_once(bypass, "POST", "/blocks/BLC123/actions/disable", fn conn ->
        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(200, Jason.encode!(%{"blocks" => block}))
      end)

      assert {:ok, result} = Blocks.disable(client, "BLC123")
      assert result["active"] == false
    end

    test "enable POSTs to action", %{client: client, bypass: bypass} do
      block = build(:block, %{"active" => true})

      Bypass.expect_once(bypass, "POST", "/blocks/BLC123/actions/enable", fn conn ->
        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(200, Jason.encode!(%{"blocks" => block}))
      end)

      assert {:ok, _} = Blocks.enable(client, "BLC123")
    end
  end
end
