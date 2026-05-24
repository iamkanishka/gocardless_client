defmodule GoCardlessClient.Resources.CustomersTest do
  use GoCardlessClient.TestCase

  alias GoCardlessClient.Resources.Customers
  alias Plug.Conn

  describe "create/3" do
    test "POSTs to /customers and returns the customer", %{client: client, bypass: bypass} do
      customer = build(:customer)

      Bypass.expect_once(bypass, "POST", "/customers", fn conn ->
        {:ok, body, conn} = Conn.read_body(conn)
        parsed = Jason.decode!(body)
        assert parsed["customers"]["email"] == "alice@example.com"

        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(201, Jason.encode!(%{"customers" => customer}))
      end)

      assert {:ok, result} = Customers.create(client, %{email: "alice@example.com"})
      assert result["email"] == "alice@example.com"
    end

    test "returns APIError on validation failure", %{client: client, bypass: bypass} do
      error_body = %{
        "error" => %{
          "message" => "Validation failed",
          "type" => "validation_error",
          "code" => 422,
          "errors" => [%{"field" => "email", "message" => "is invalid"}]
        }
      }

      Bypass.expect_once(bypass, "POST", "/customers", fn conn ->
        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(422, Jason.encode!(error_body))
      end)

      assert {:error, error} = Customers.create(client, %{email: "bad"})
      assert error.type == "validation_error"
    end
  end

  describe "get/3" do
    test "GETs /customers/:id and returns the customer", %{client: client, bypass: bypass} do
      customer = build(:customer, %{"id" => "CU123"})

      Bypass.expect_once(bypass, "GET", "/customers/CU123", fn conn ->
        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(200, Jason.encode!(%{"customers" => customer}))
      end)

      assert {:ok, result} = Customers.get(client, "CU123")
      assert result["id"] == "CU123"
    end

    test "returns APIError for not found", %{client: client, bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/customers/NOTFOUND", fn conn ->
        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(
          404,
          Jason.encode!(%{
            "error" => %{
              "type" => "invalid_api_usage",
              "code" => 404,
              "message" => "Not found",
              "errors" => []
            }
          })
        )
      end)

      assert {:error, error} = Customers.get(client, "NOTFOUND")
      assert error.code == 404
    end
  end

  describe "list/3" do
    test "GETs /customers and returns items and meta", %{client: client, bypass: bypass} do
      customers = build_list(3, :customer)

      Bypass.expect_once(bypass, "GET", "/customers", fn conn ->
        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(
          200,
          Jason.encode!(%{
            "customers" => customers,
            "meta" => %{"cursors" => %{"before" => nil, "after" => nil}}
          })
        )
      end)

      assert {:ok, %{items: items, meta: meta}} = Customers.list(client)
      assert length(items) == 3
      assert is_map(meta)
    end

    test "passes filter params as query string", %{client: client, bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/customers", fn conn ->
        params = URI.decode_query(conn.query_string)
        assert params["email"] == "alice@example.com"

        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(
          200,
          Jason.encode!(%{
            "customers" => [],
            "meta" => %{"cursors" => %{"before" => nil, "after" => nil}}
          })
        )
      end)

      assert {:ok, _} = Customers.list(client, %{email: "alice@example.com"})
    end
  end

  describe "update/4" do
    test "POSTs (not PUT) to /customers/:id", %{client: client, bypass: bypass} do
      customer = build(:customer, %{"id" => "CU123", "email" => "new@example.com"})

      Bypass.expect_once(bypass, "POST", "/customers/CU123", fn conn ->
        {:ok, body, conn} = Conn.read_body(conn)
        parsed = Jason.decode!(body)
        assert Map.has_key?(parsed, "customers"), "body must be wrapped in resource key"

        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(200, Jason.encode!(%{"customers" => customer}))
      end)

      assert {:ok, result} = Customers.update(client, "CU123", %{email: "new@example.com"})
      assert result["email"] == "new@example.com"
    end
  end

  describe "remove/3" do
    test "DELETEs /customers/:id for GDPR erasure", %{client: client, bypass: bypass} do
      Bypass.expect_once(bypass, "DELETE", "/customers/CU123", fn conn ->
        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(200, Jason.encode!(%{"customers" => %{"id" => "CU123"}}))
      end)

      assert {:ok, _} = Customers.remove(client, "CU123")
    end
  end

  describe "request headers" do
    test "sends correct GoCardless-Version header", %{client: client, bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/customers/CU1", fn conn ->
        version = conn |> get_req_header("gocardless-version") |> List.first()
        assert version == "2015-07-06"

        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(200, Jason.encode!(%{"customers" => build(:customer)}))
      end)

      Customers.get(client, "CU1")
    end

    test "sends Authorization header", %{client: client, bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/customers/CU1", fn conn ->
        auth = conn |> get_req_header("authorization") |> List.first()
        assert auth == "Bearer test_token_sandbox"

        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(200, Jason.encode!(%{"customers" => build(:customer)}))
      end)

      Customers.get(client, "CU1")
    end

    test "sends Idempotency-Key header when provided", %{client: client, bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/customers", fn conn ->
        key = conn |> get_req_header("idempotency-key") |> List.first()
        assert key == "my-idempotency-key"

        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(201, Jason.encode!(%{"customers" => build(:customer)}))
      end)

      Customers.create(client, %{email: "a@b.com"}, idempotency_key: "my-idempotency-key")
    end
  end

  defp get_req_header(conn, header) do
    conn.req_headers
    |> Enum.filter(fn {k, _} -> String.downcase(k) == header end)
    |> Enum.map(fn {_, v} -> v end)
  end
end
