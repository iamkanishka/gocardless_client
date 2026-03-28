defmodule GoCardlessClient.TestCase do
  @moduledoc """
  Base test case for GoCardlessClient integration tests using Bypass.

  Sets up a local HTTP server (Bypass) that intercepts all GoCardlessClient API calls,
  allowing tests to run without real network requests.

  ## Usage

      defmodule MyTest do
        use GoCardlessClient.TestCase

        test "creates a customer", %{client: client, bypass: bypass} do
          customer = GoCardlessClient.Factory.build(:customer)

          Bypass.expect_once(bypass, "POST", "/customers", fn conn ->
            conn
            |> Plug.Conn.put_resp_content_type("application/json")
            |> Plug.Conn.send_resp(200, Jason.encode!(%{"customers" => customer}))
          end)

          assert {:ok, ^customer} = GoCardlessClient.Resources.Customers.create(client, %{
            email: customer["email"]
          })
        end
      end
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import GoCardlessClient.Factory
      alias GoCardlessClient.{Client, Resources}

      # Assert that {:ok, result} matches expected
      defmacro assert_ok({:ok, value}, do: block) do
        quote do
          var!(value) = unquote(value)
          unquote(block)
        end
      end
    end
  end

  setup do
    bypass = Bypass.open()

    client =
      GoCardlessClient.Client.new!(
        access_token: "test_token",
        environment: :sandbox,
        max_retries: 0,
        finch_name: GoCardlessClient.Finch
      )

    # Override the base URL to point at Bypass
    config = %{client.config | access_token: "test_token"}
    base_url = "http://localhost:#{bypass.port}"
    config = Map.put(config, :_base_url_override, base_url)

    patched_client = %{client | config: config}

    {:ok, bypass: bypass, client: patched_client, base_bypass_url: base_url}
  end
end
