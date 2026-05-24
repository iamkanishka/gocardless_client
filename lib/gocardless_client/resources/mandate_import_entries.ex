defmodule GoCardlessClient.Resources.MandateImportEntries do
  @moduledoc """
  GoCardless Mandate Import Entries API.

  Individual mandate records within a Mandate Import batch. Add entries before
  submitting the import.

  ## Example

      {:ok, _entry} = GoCardlessClient.Resources.MandateImportEntries.add(client, %{
        record_identifier: "CUST-001",
        amendment: %{
          original_creditor_id: "OLD-CR-001",
          original_creditor_name: "Old Provider Ltd",
          original_mandate_reference: "OLD-REF-001"
        },
        customer: %{
          given_name: "Alice",
          family_name: "Smith",
          email: "alice@example.com",
          address_line1: "1 Example St",
          city: "London",
          postal_code: "EC1A 1BB",
          country_code: "GB"
        },
        bank_account: %{
          account_holder_name: "Alice Smith",
          sort_code: "200000",
          account_number: "55779911"
        },
        links: %{mandate_import: "IM123"}
      })
  """

  alias GoCardlessClient.{Client, Paginator, Resource}

  @resource_key "mandate_import_entries"
  @base_path "/mandate_import_entries"

  @doc """
  Adds a mandate entry to a mandate import batch.

  ## Params

  - `:record_identifier` — your internal reference for this entry (required)
  - `:amendment` — contains `original_creditor_id`, `original_creditor_name`,
    `original_mandate_reference` (required)
  - `:customer` — customer details map (required)
  - `:bank_account` — bank account details map (required)
  - `links.mandate_import` — Mandate Import ID (required)
  """
  @spec add(Client.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def add(%Client{} = client, params, opts \\ []) do
    Resource.post(client, @base_path, @resource_key, params, opts)
  end

  @doc "Lists all mandate import entries for a given import. Filter by `:mandate_import` (required)."
  @spec list(Client.t(), map(), keyword()) ::
          {:ok, %{items: [map()], meta: map()}}
          | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def list(%Client{} = client, params \\ %{}, opts \\ []) do
    Resource.list(client, @base_path, @resource_key, params, opts)
  end

  @doc "Returns a lazy `Stream` over all entries for a given import."
  @spec stream(Client.t(), map(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.stream(client, @base_path, params, @resource_key, opts)
  end

  @doc "Eagerly collects all entries into a list."
  @spec collect_all(Client.t(), map(), keyword()) ::
          {:ok, [map()]} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def collect_all(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.collect(client, @base_path, params, @resource_key, opts)
  end
end
