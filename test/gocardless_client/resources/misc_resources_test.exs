defmodule GoCardlessClient.Resources.MiscResourcesTest do
  use GoCardlessClient.TestCase

  alias GoCardlessClient.Resources.Balances
  alias GoCardlessClient.Resources.BankDetailsLookups
  alias GoCardlessClient.Resources.CustomerNotifications
  alias GoCardlessClient.Resources.FundsAvailabilities
  alias GoCardlessClient.Resources.Institutions
  alias GoCardlessClient.Resources.MandatePDFs
  alias Plug.Conn

  describe "BankDetailsLookups.lookup/3" do
    test "POSTs to /bank_details_lookups", %{client: client, bypass: bypass} do
      result = build(:bank_details_lookup)

      Bypass.expect_once(bypass, "POST", "/bank_details_lookups", fn conn ->
        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(200, Jason.encode!(%{"bank_details_lookups" => result}))
      end)

      assert {:ok, details} = BankDetailsLookups.lookup(client, %{
        account_number: "55779911",
        branch_code: "200000",
        country_code: "GB"
      })
      assert details["bank_name"] == "BARCLAYS BANK PLC"
      assert details["available_debit_schemes"] == ["bacs"]
    end
  end

  describe "FundsAvailabilities.check/3" do
    test "POSTs to /funds_availabilities", %{client: client, bypass: bypass} do
      result = build(:funds_availability)

      Bypass.expect_once(bypass, "POST", "/funds_availabilities", fn conn ->
        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(200, Jason.encode!(%{"funds_availabilities" => result}))
      end)

      assert {:ok, %{"available" => true}} =
               FundsAvailabilities.check(client, %{amount: 50_000, currency: "GBP"})
    end
  end

  describe "MandatePDFs.create/3" do
    test "POSTs to /mandate_pdfs", %{client: client, bypass: bypass} do
      result = %{
        "url" => "https://api.gocardless.com/pdfs/MD123.pdf",
        "expires_at" => "2025-02-01T00:00:00.000Z"
      }

      Bypass.expect_once(bypass, "POST", "/mandate_pdfs", fn conn ->
        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(201, Jason.encode!(%{"mandate_pdfs" => result}))
      end)

      assert {:ok, pdf} = MandatePDFs.create(client, %{links: %{mandate: "MD123"}})
      assert pdf["url"] =~ "MD123"
    end
  end

  describe "Institutions.list/3" do
    test "GETs /institutions with country_code filter", %{client: client, bypass: bypass} do
      institutions = build_list(3, :institution)

      Bypass.expect_once(bypass, "GET", "/institutions", fn conn ->
        params = URI.decode_query(conn.query_string)
        assert params["country_code"] == "GB"

        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(200, Jason.encode!(%{
          "institutions" => institutions,
          "meta" => %{"cursors" => %{"before" => nil, "after" => nil}}
        }))
      end)

      assert {:ok, %{items: items}} = Institutions.list(client, %{country_code: "GB"})
      assert length(items) == 3
    end
  end

  describe "Institutions.list_for_billing_request/4" do
    test "GETs /billing_requests/:id/institutions", %{client: client, bypass: bypass} do
      institutions = build_list(2, :institution)

      Bypass.expect_once(bypass, "GET", "/billing_requests/BRQ123/institutions", fn conn ->
        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(200, Jason.encode!(%{
          "institutions" => institutions,
          "meta" => %{"cursors" => %{"before" => nil, "after" => nil}}
        }))
      end)

      assert {:ok, %{items: items}} =
               Institutions.list_for_billing_request(client, "BRQ123")
      assert length(items) == 2
    end
  end

  describe "Balances.list/3" do
    test "GETs /balances", %{client: client, bypass: bypass} do
      balances = build_list(2, :balance)

      Bypass.expect_once(bypass, "GET", "/balances", fn conn ->
        conn
        |> Conn.put_resp_content_type("application/json")
        |> Conn.send_resp(200, Jason.encode!(%{
          "balances" => balances,
          "meta" => %{"cursors" => %{"before" => nil, "after" => nil}}
        }))
      end)

      assert {:ok, %{items: items}} = Balances.list(client)
      assert length(items) == 2
    end
  end

  describe "CustomerNotifications.handle/4" do
    test "POSTs to handle action", %{client: client, bypass: bypass} do
      Bypass.expect_once(
        bypass,
        "POST",
        "/customer_notifications/CN123/actions/handle",
        fn conn ->
          conn
          |> Conn.put_resp_content_type("application/json")
          |> Conn.send_resp(200, Jason.encode!(%{"customer_notifications" => %{}}))
        end
      )

      assert {:ok, _} = CustomerNotifications.handle(client, "CN123")
    end
  end
end
