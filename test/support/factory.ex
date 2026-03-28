defmodule GoCardlessClient.Factory do
  @moduledoc "Test fixture factory for GoCardlessClient resources."

  def build(:customer) do
    %{
      "id" => "CU#{unique_id()}",
      "created_at" => "2024-01-15T10:00:00.000Z",
      "email" => "alice@example.com",
      "given_name" => "Alice",
      "family_name" => "Smith",
      "company_name" => nil,
      "address_line1" => "1 Example Street",
      "address_line2" => nil,
      "address_line3" => nil,
      "city" => "London",
      "region" => nil,
      "postal_code" => "EC1A 1BB",
      "country_code" => "GB",
      "language" => "en",
      "phone_number" => nil,
      "metadata" => %{}
    }
  end

  def build(:customer_bank_account) do
    %{
      "id" => "BA#{unique_id()}",
      "created_at" => "2024-01-15T10:00:00.000Z",
      "account_holder_name" => "Alice Smith",
      "account_number_ending" => "11",
      "bank_name" => "BARCLAYS BANK PLC",
      "country_code" => "GB",
      "currency" => "GBP",
      "enabled" => true,
      "metadata" => %{},
      "links" => %{"customer" => "CU#{unique_id()}"}
    }
  end

  def build(:mandate) do
    %{
      "id" => "MD#{unique_id()}",
      "created_at" => "2024-01-15T10:00:00.000Z",
      "status" => "active",
      "scheme" => "bacs",
      "reference" => "REF-#{unique_id()}",
      "next_possible_charge_date" => "2024-02-01",
      "metadata" => %{},
      "links" => %{
        "customer_bank_account" => "BA#{unique_id()}",
        "customer" => "CU#{unique_id()}",
        "creditor" => "CR#{unique_id()}"
      }
    }
  end

  def build(:payment) do
    %{
      "id" => "PM#{unique_id()}",
      "created_at" => "2024-01-15T10:00:00.000Z",
      "charge_date" => "2024-02-01",
      "amount" => 1500,
      "description" => "Monthly fee",
      "currency" => "GBP",
      "status" => "pending_submission",
      "amount_refunded" => 0,
      "reference" => nil,
      "metadata" => %{},
      "links" => %{
        "mandate" => "MD#{unique_id()}",
        "creditor" => "CR#{unique_id()}"
      }
    }
  end

  def build(:subscription) do
    %{
      "id" => "SB#{unique_id()}",
      "created_at" => "2024-01-15T10:00:00.000Z",
      "amount" => 2500,
      "currency" => "GBP",
      "status" => "active",
      "name" => "Premium Monthly",
      "start_date" => "2024-02-01",
      "end_date" => nil,
      "interval" => 1,
      "interval_unit" => "monthly",
      "day_of_month" => 1,
      "month" => nil,
      "payment_reference" => nil,
      "upcoming_payments" => [
        %{"charge_date" => "2024-02-01", "amount" => 2500},
        %{"charge_date" => "2024-03-01", "amount" => 2500}
      ],
      "metadata" => %{},
      "links" => %{"mandate" => "MD#{unique_id()}"}
    }
  end

  def build(:billing_request) do
    %{
      "id" => "BRQ#{unique_id()}",
      "created_at" => "2024-01-15T10:00:00.000Z",
      "status" => "pending",
      "actions" => [],
      "fallback_enabled" => false,
      "fallback_occurred" => false,
      "payment_request" => nil,
      "mandate_request" => nil,
      "resources" => %{},
      "metadata" => %{},
      "links" => %{}
    }
  end

  def build(:redirect_flow) do
    %{
      "id" => "RE#{unique_id()}",
      "created_at" => "2024-01-15T10:00:00.000Z",
      "description" => "Set up your Direct Debit",
      "session_token" => "sess_#{unique_id()}",
      "success_redirect_url" => "https://example.com/success",
      "redirect_url" => "https://pay-sandbox.gocardless.com/obauth/RE#{unique_id()}",
      "links" => %{}
    }
  end

  def build(:payout) do
    %{
      "id" => "PO#{unique_id()}",
      "created_at" => "2024-01-15T10:00:00.000Z",
      "amount" => 50_000,
      "currency" => "GBP",
      "status" => "paid",
      "paid_at" => "2024-01-16T10:00:00.000Z",
      "reference" => "GC-#{unique_id()}",
      "deducted_fees" => 150,
      "metadata" => %{},
      "links" => %{"creditor" => "CR#{unique_id()}"}
    }
  end

  def build(:refund) do
    %{
      "id" => "RF#{unique_id()}",
      "created_at" => "2024-01-15T10:00:00.000Z",
      "amount" => 500,
      "status" => "created",
      "reference" => "REFUND-001",
      "currency" => "GBP",
      "metadata" => %{},
      "links" => %{"payment" => "PM#{unique_id()}"}
    }
  end

  def build(:event) do
    %{
      "id" => "EV#{unique_id()}",
      "created_at" => "2024-01-15T10:00:00.000Z",
      "action" => "paid_out",
      "resource_type" => "payments",
      "details" => %{
        "origin" => "gocardless",
        "cause" => "payment_paid_out",
        "description" => "Payment paid out."
      },
      "metadata" => %{},
      "links" => %{"payment" => "PM#{unique_id()}"}
    }
  end

  def build(:webhook_payload) do
    %{"events" => [build(:event)]}
  end

  def build(:webhook_payload, events: events) do
    %{"events" => events}
  end

  def build(factory, attrs) when is_map(attrs) do
    Map.merge(build(factory), attrs)
  end

  def build_list(n, factory, attrs \\ %{}) do
    Enum.map(1..n, fn _ -> build(factory, attrs) end)
  end

  defp unique_id do
    :crypto.strong_rand_bytes(6) |> Base.encode16(case: :lower)
  end
end
