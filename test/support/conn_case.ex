defmodule GoCardlessClient.TestCase do
  @moduledoc """
  Base test case for GoCardlessClient resource tests using Bypass.

  Sets up a local HTTP server (Bypass) and a Client that points at it,
  so all tests run without real network requests.

  ## Usage

      defmodule MyTest do
        use GoCardlessClient.TestCase
  alias Plug.Conn

        test "creates a customer", %{client: client, bypass: bypass} do
          customer = build(:customer)

          Bypass.expect_once(bypass, "POST", "/customers", fn conn ->
            Conn.put_resp_content_type(conn, "application/json")
            |> Conn.send_resp(200, Jason.encode!(%{"customers" => customer}))
          end)

          assert {:ok, ^customer} = GoCardlessClient.Resources.Customers.create(
            client,
            %{email: customer["email"]}
          )
        end
      end
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import GoCardlessClient.Factory
      alias GoCardlessClient.{Client, Resources}
    end
  end

  setup do
    bypass = Bypass.open()
    base_url = "http://localhost:#{bypass.port}"

    # Build a client that points at the Bypass server, not the real GoCardless API.
    # The _base_url_override key in config is read by GoCardlessClient.HTTP.Client.
    config =
      GoCardlessClient.Config.new!(
        access_token: "test_token_sandbox",
        environment: :sandbox,
        max_retries: 0,
        finch_name: GoCardlessClient.Finch
      )

    config = Map.put(config, :_base_url_override, base_url)
    client = %GoCardlessClient.Client{config: config}

    {:ok, bypass: bypass, client: client, base_bypass_url: base_url}
  end
end
