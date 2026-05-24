defmodule GoCardlessClient.Factory do
  @moduledoc "Test data factories for GoCardlessClient resource tests."

  def build(factory, attrs \\ %{})

  def build(:customer, attrs) do
    base = %{
      "id" => "CU#{unique_id()}",
      "created_at" => "2024-01-15T10:00:00.000Z",
      "email" => "alice@example.com",
      "given_name" => "Alice",
      "family_name" => "Smith",
      "address_line1" => "1 Example Street",
      "city" => "London",
      "postal_code" => "EC1A 1BB",
      "country_code" => "GB",
      "language" => "en",
      "metadata" => %{},
      "links" => %{}
    }

    Map.merge(base, attrs)
  end

  def build(:customer_bank_account, attrs) do
    base = %{
      "id" => "BA#{unique_id()}",
      "created_at" => "2024-01-15T10:00:00.000Z",
      "account_holder_name" => "Alice Smith",
      "account_number_ending" => "11",
      "bank_name" => "BARCLAYS BANK PLC",
      "currency" => "GBP",
      "country_code" => "GB",
      "enabled" => true,
      "metadata" => %{},
      "links" => %{"customer" => "CU#{unique_id()}"}
    }

    Map.merge(base, attrs)
  end

  def build(:mandate, attrs) do
    base = %{
      "id" => "MD#{unique_id()}",
      "created_at" => "2024-01-15T10:00:00.000Z",
      "status" => "active",
      "scheme" => "bacs",
      "reference" => "REF-#{unique_id()}",
      "next_possible_charge_date" => "2025-02-01",
      "metadata" => %{},
      "links" => %{
        "customer_bank_account" => "BA#{unique_id()}",
        "customer" => "CU#{unique_id()}",
        "creditor" => "CR#{unique_id()}"
      }
    }

    Map.merge(base, attrs)
  end

  def build(:payment, attrs) do
    base = %{
      "id" => "PM#{unique_id()}",
      "created_at" => "2024-01-15T10:00:00.000Z",
      "amount" => 1500,
      "currency" => "GBP",
      "status" => "confirmed",
      "charge_date" => "2025-02-01",
      "description" => "Test payment",
      "amount_refunded" => 0,
      "metadata" => %{},
      "links" => %{
        "mandate" => "MD#{unique_id()}",
        "creditor" => "CR#{unique_id()}"
      }
    }

    Map.merge(base, attrs)
  end

  def build(:subscription, attrs) do
    base = %{
      "id" => "SB#{unique_id()}",
      "created_at" => "2024-01-15T10:00:00.000Z",
      "amount" => 2500,
      "currency" => "GBP",
      "status" => "active",
      "name" => "Monthly plan",
      "interval_unit" => "monthly",
      "interval" => 1,
      "day_of_month" => 1,
      "metadata" => %{},
      "upcoming_payments" => [],
      "links" => %{"mandate" => "MD#{unique_id()}"}
    }

    Map.merge(base, attrs)
  end

  def build(:billing_request, attrs) do
    base = %{
      "id" => "BRQ#{unique_id()}",
      "created_at" => "2024-01-15T10:00:00.000Z",
      "status" => "pending",
      "actions" => [],
      "resources" => %{},
      "links" => %{}
    }

    Map.merge(base, attrs)
  end

  def build(:redirect_flow, attrs) do
    base = %{
      "id" => "RE#{unique_id()}",
      "created_at" => "2024-01-15T10:00:00.000Z",
      "description" => "Set up Direct Debit",
      "session_token" => "sess_#{unique_id()}",
      "scheme" => "bacs",
      "redirect_url" => "https://pay-sandbox.gocardless.com/obauth/RE#{unique_id()}",
      "links" => %{}
    }

    Map.merge(base, attrs)
  end

  def build(:payout, attrs) do
    base = %{
      "id" => "PO#{unique_id()}",
      "created_at" => "2024-01-15T10:00:00.000Z",
      "amount" => 125_000,
      "currency" => "GBP",
      "status" => "paid",
      "arrival_date" => "2025-01-17",
      "deducted_fees" => 150,
      "payout_type" => "merchant",
      "reference" => "GC-#{unique_id()}",
      "tax_currency" => nil,
      "links" => %{"creditor" => "CR#{unique_id()}"}
    }

    Map.merge(base, attrs)
  end

  def build(:refund, attrs) do
    base = %{
      "id" => "RF#{unique_id()}",
      "created_at" => "2024-01-15T10:00:00.000Z",
      "amount" => 500,
      "currency" => "GBP",
      "status" => "created",
      "reference" => nil,
      "metadata" => %{},
      "links" => %{"payment" => "PM#{unique_id()}"}
    }

    Map.merge(base, attrs)
  end

  def build(:event, attrs) do
    base = %{
      "id" => "EV#{unique_id()}",
      "created_at" => "2024-01-15T10:00:00.000Z",
      "action" => "paid_out",
      "resource_type" => "payments",
      "links" => %{"payment" => "PM#{unique_id()}"},
      "details" => %{
        "origin" => "gocardless",
        "cause" => "payment_paid_out",
        "description" => "Payment paid out by GoCardless"
      },
      "metadata" => {}
    }

    Map.merge(base, attrs)
  end

  def build(:billing_request_flow, attrs) do
    base = %{
      "id" => "BRF#{unique_id()}",
      "created_at" => "2024-01-15T10:00:00.000Z",
      "redirect_uri" => "https://example.com/complete",
      "exit_uri" => "https://example.com/cancel",
      "authorisation_url" => "https://pay-sandbox.gocardless.com/obauth/BRQ#{unique_id()}",
      "expires_at" => "2024-01-15T12:00:00.000Z",
      "session_token" => nil,
      "links" => %{"billing_request" => "BRQ#{unique_id()}"}
    }

    Map.merge(base, attrs)
  end

  def build(:mandate_import, attrs) do
    base = %{
      "id" => "IM#{unique_id()}",
      "created_at" => "2024-01-15T10:00:00.000Z",
      "scheme" => "bacs",
      "status" => "created",
      "links" => %{}
    }

    Map.merge(base, attrs)
  end

  def build(:mandate_import_entry, attrs) do
    base = %{
      "created_at" => "2024-01-15T10:00:00.000Z",
      "record_identifier" => "CUST-001",
      "processing_errors" => nil,
      "links" => %{
        "mandate_import" => "IM#{unique_id()}",
        "customer" => "CU#{unique_id()}",
        "customer_bank_account" => "BA#{unique_id()}",
        "mandate" => "MD#{unique_id()}"
      }
    }

    Map.merge(base, attrs)
  end

  def build(:payment_account, attrs) do
    base = %{
      "id" => "PA#{unique_id()}",
      "created_at" => "2024-01-15T10:00:00.000Z",
      "currency" => "GBP",
      "balance" => 250_000,
      "links" => %{"creditor" => "CR#{unique_id()}"}
    }

    Map.merge(base, attrs)
  end

  def build(:outbound_payment, attrs) do
    base = %{
      "id" => "OP#{unique_id()}",
      "created_at" => "2024-01-15T10:00:00.000Z",
      "amount" => 5000,
      "currency" => "GBP",
      "description" => "Supplier payment",
      "status" => "created",
      "metadata" => %{},
      "links" => %{
        "payment_account" => "PA#{unique_id()}",
        "creditor" => "CR#{unique_id()}"
      }
    }

    Map.merge(base, attrs)
  end

  def build(:outbound_payment_import, attrs) do
    base = %{
      "id" => "OPI#{unique_id()}",
      "created_at" => "2024-01-15T10:00:00.000Z",
      "currency" => "GBP",
      "status" => "created",
      "links" => %{"payment_account" => "PA#{unique_id()}"}
    }

    Map.merge(base, attrs)
  end

  def build(:block, attrs) do
    base = %{
      "id" => "BLC#{unique_id()}",
      "created_at" => "2024-01-15T10:00:00.000Z",
      "block_type" => "email",
      "reason_type" => "fraud",
      "resource_reference" => "fraudster@example.com",
      "active" => true
    }

    Map.merge(base, attrs)
  end

  def build(:instalment_schedule, attrs) do
    base = %{
      "id" => "IS#{unique_id()}",
      "created_at" => "2024-01-15T10:00:00.000Z",
      "name" => "3-month plan",
      "currency" => "GBP",
      "status" => "active",
      "total_amount" => 15_000,
      "payment_errors_count" => 0,
      "metadata" => %{},
      "links" => %{"mandate" => "MD#{unique_id()}"}
    }

    Map.merge(base, attrs)
  end

  def build(:creditor, attrs) do
    base = %{
      "id" => "CR#{unique_id()}",
      "created_at" => "2024-01-15T10:00:00.000Z",
      "name" => "Acme Ltd",
      "address_line1" => "1 Example Street",
      "city" => "London",
      "postal_code" => "EC1A 1BB",
      "country_code" => "GB",
      "verification_status" => "successful",
      "links" => %{}
    }

    Map.merge(base, attrs)
  end

  def build(:creditor_bank_account, attrs) do
    base = %{
      "id" => "BA#{unique_id()}",
      "created_at" => "2024-01-15T10:00:00.000Z",
      "account_holder_name" => "Acme Ltd",
      "account_number_ending" => "11",
      "bank_name" => "BARCLAYS BANK PLC",
      "currency" => "GBP",
      "enabled" => true,
      "is_default_payout_account" => true,
      "links" => %{"creditor" => "CR#{unique_id()}"}
    }

    Map.merge(base, attrs)
  end

  def build(:scheme_identifier, attrs) do
    base = %{
      "id" => "SCI#{unique_id()}",
      "created_at" => "2024-01-15T10:00:00.000Z",
      "name" => "Acme Payments",
      "scheme" => "bacs",
      "status" => "activated",
      "reference" => "ACMEPAY",
      "links" => %{"creditor" => "CR#{unique_id()}"}
    }

    Map.merge(base, attrs)
  end

  def build(:tax_rate, attrs) do
    base = %{
      "id" => "TAX#{unique_id()}",
      "jurisdiction" => "GB",
      "percentage" => "20.0",
      "type" => "vat",
      "start_date" => "2011-01-04",
      "end_date" => nil
    }

    Map.merge(base, attrs)
  end

  def build(:institution, attrs) do
    base = %{
      "id" => "MONZO",
      "name" => "Monzo",
      "icon_url" => "https://example.com/monzo-icon.png",
      "logo_url" => "https://example.com/monzo-logo.png",
      "country_code" => "GB"
    }

    Map.merge(base, attrs)
  end

  def build(:bank_authorisation, attrs) do
    base = %{
      "id" => "BAU#{unique_id()}",
      "created_at" => "2024-01-15T10:00:00.000Z",
      "authorisation_type" => "mandate",
      "authorisation_url" => "https://pay-sandbox.gocardless.com/obauth/BAU#{unique_id()}",
      "status" => "created",
      "expires_at" => "2024-01-15T12:00:00.000Z",
      "links" => %{"billing_request" => "BRQ#{unique_id()}"}
    }

    Map.merge(base, attrs)
  end

  def build(:payout_item, attrs) do
    base = %{
      "type" => "payment_paid_out",
      "amount" => %{"amount" => "1500", "currency" => "GBP"},
      "links" => %{
        "payment" => "PM#{unique_id()}",
        "payout" => "PO#{unique_id()}"
      }
    }

    Map.merge(base, attrs)
  end

  def build(:bank_details_lookup, attrs) do
    base = %{
      "bank_name" => "BARCLAYS BANK PLC",
      "bic" => "BARCGB22",
      "available_debit_schemes" => ["bacs"]
    }

    Map.merge(base, attrs)
  end

  def build(:funds_availability, attrs) do
    base = %{"available" => true, "available_at" => nil}
    Map.merge(base, attrs)
  end

  def build(:balance, attrs) do
    base = %{
      "amount" => 250_000,
      "currency" => "GBP",
      "type" => "creditor_account",
      "links" => %{"creditor" => "CR#{unique_id()}"}
    }

    Map.merge(base, attrs)
  end

  def build(:exchange_rate, attrs) do
    base = %{
      "source" => "GBP",
      "target" => "EUR",
      "rate" => "1.1650",
      "time" => "2024-01-15T10:00:00.000Z"
    }

    Map.merge(base, attrs)
  end

  def build(:verification_detail, attrs) do
    base = %{
      "id" => "VD#{unique_id()}",
      "created_at" => "2024-01-15T10:00:00.000Z",
      "name_on_account" => "Acme Ltd",
      "address_line1" => "1 Example Street",
      "city" => "London",
      "postal_code" => "EC1A 1BB",
      "country_code" => "GB",
      "description" => "B2B SaaS platform",
      "links" => %{"creditor" => "CR#{unique_id()}"}
    }

    Map.merge(base, attrs)
  end

  def build(:webhook_record, attrs) do
    base = %{
      "id" => "WB#{unique_id()}",
      "created_at" => "2024-01-15T10:00:00.000Z",
      "url" => "https://myapp.com/webhooks/gocardless",
      "successful" => true,
      "response_code" => 200,
      "request_body" => Jason.encode!(%{"events" => []}),
      "response_body" => "OK"
    }

    Map.merge(base, attrs)
  end

  def build(:negative_balance_limit, attrs) do
    base = %{
      "id" => "NBL#{unique_id()}",
      "currency" => "GBP",
      "balance_limit" => -50_000,
      "links" => %{"creditor" => "CR#{unique_id()}"}
    }

    Map.merge(base, attrs)
  end

  def build_list(n, factory, attrs \\ %{}) do
    Enum.map(1..n, fn _ -> build(factory, attrs) end)
  end

  defp unique_id do
    :crypto.strong_rand_bytes(6) |> Base.encode16(case: :lower)
  end
end
