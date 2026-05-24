defmodule GoCardlessClient.Resources.InstalmentSchedulesTest do
  use GoCardlessClient.TestCase

  alias GoCardlessClient.Resources.InstalmentSchedules
  alias Plug.Conn

  describe "create_with_dates/3" do
    test "creates schedule with explicit dates", %{client: client, bypass: bypass} do
      schedule = build(:instalment_schedule)

      Bypass.expect_once(bypass, "POST", "/instalment_schedules", fn conn ->
        {:ok, body, conn} = Conn.read_body(conn)
        parsed = Jason.decode!(body)
        assert Map.has_key?(parsed, "instalment_schedules")
        assert is_list(parsed["instalment_schedules"]["instalments"])

        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(201, Jason.encode!(%{"instalment_schedules" => schedule}))
      end)

      assert {:ok, _} =
               InstalmentSchedules.create_with_dates(client, %{
                 name: "3-month plan",
                 currency: "GBP",
                 instalments: [
                   %{charge_date: "2025-02-01", amount: 5000},
                   %{charge_date: "2025-03-01", amount: 5000},
                   %{charge_date: "2025-04-01", amount: 5000}
                 ],
                 links: %{mandate: "MD123"}
               })
    end
  end

  describe "create_with_schedule/3" do
    test "creates schedule with interval config", %{client: client, bypass: bypass} do
      schedule = build(:instalment_schedule)

      Bypass.expect_once(bypass, "POST", "/instalment_schedules", fn conn ->
        {:ok, body, conn} = Conn.read_body(conn)
        parsed = Jason.decode!(body)
        assert parsed["instalment_schedules"]["interval_unit"] == "monthly"

        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(201, Jason.encode!(%{"instalment_schedules" => schedule}))
      end)

      assert {:ok, _} =
               InstalmentSchedules.create_with_schedule(client, %{
                 name: "6-month plan",
                 currency: "GBP",
                 amount: 3000,
                 start_date: "2025-02-01",
                 count: 6,
                 interval_unit: "monthly",
                 interval: 1,
                 links: %{mandate: "MD123"}
               })
    end
  end

  describe "cancel/4" do
    test "POSTs to cancel action", %{client: client, bypass: bypass} do
      schedule = build(:instalment_schedule, %{"status" => "cancelled"})

      Bypass.expect_once(bypass, "POST", "/instalment_schedules/IS123/actions/cancel", fn conn ->
        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(200, Jason.encode!(%{"instalment_schedules" => schedule}))
      end)

      assert {:ok, result} = InstalmentSchedules.cancel(client, "IS123")
      assert result["status"] == "cancelled"
    end
  end
end
