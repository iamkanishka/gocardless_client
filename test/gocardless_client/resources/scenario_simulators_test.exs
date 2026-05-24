defmodule GoCardlessClient.Resources.ScenarioSimulatorsTest do
  use GoCardlessClient.TestCase

  alias GoCardlessClient.Resources.ScenarioSimulators
  alias Plug.Conn

  describe "run/4" do
    test "POSTs to correct action path", %{client: client, bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/scenario_simulators/payment_paid_out/actions/run", fn conn ->
        {:ok, body, conn} = Conn.read_body(conn)
        parsed = Jason.decode!(body)
        assert parsed["scenario_simulators"]["links"]["payment"] == "PM123"

        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(200, Jason.encode!(%{}))
      end)

      assert {:ok, _} = ScenarioSimulators.run(client, "payment_paid_out", %{
        links: %{payment: "PM123"}
      })
    end

    test "works for mandate scenarios", %{client: client, bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/scenario_simulators/mandate_failed/actions/run", fn conn ->
        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(200, Jason.encode!(%{}))
      end)

      assert {:ok, _} = ScenarioSimulators.run(client, "mandate_failed", %{
        links: %{mandate: "MD456"}
      })
    end

    test "raises ArgumentError for unknown scenario type", %{client: client} do
      assert_raise ArgumentError, ~r/Unknown scenario type/, fn ->
        ScenarioSimulators.run(client, "not_a_real_scenario", %{})
      end
    end

    test "valid_scenarios/0 returns all scenario strings" do
      scenarios = ScenarioSimulators.valid_scenarios()
      assert is_list(scenarios)
      assert "payment_paid_out" in scenarios
      assert "mandate_failed" in scenarios
      assert "billing_request_fulfilled" in scenarios
    end
  end
end
