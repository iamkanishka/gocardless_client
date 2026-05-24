defmodule GoCardlessClient.Resources.VerificationDetails do
  @moduledoc """
  GoCardless Verification Details API.

  Submit KYC/KYB information for creditor verification. GoCardless uses this
  to verify your business before enabling live payments.

  ## Example

      {:ok, detail} = GoCardlessClient.Resources.VerificationDetails.create(client, %{
        name_on_account: "Acme Ltd",
        address_line1: "1 Example Street",
        city: "London",
        postal_code: "EC1A 1BB",
        country_code: "GB",
        description: "B2B SaaS subscription management platform",
        directors: [
          %{
            given_name: "Alice",
            family_name: "Smith",
            date_of_birth: "1985-06-15",
            country_of_nationality: "GB"
          }
        ],
        links: %{creditor: "CR123"}
      })
  """

  alias GoCardlessClient.{Client, Paginator, Resource}

  @resource_key "verification_details"
  @base_path "/verification_details"

  @doc """
  Submits KYC/KYB verification details for a creditor.

  ## Params

  - `:name_on_account` — business name as it appears on the bank account (required)
  - `:address_line1` — business address (required)
  - `:city` — city (required)
  - `:postal_code` — postcode/ZIP (required)
  - `:country_code` — ISO 3166-1 alpha-2 (required)
  - `:description` — brief description of your business (required)
  - `:directors` — list of director objects (each requires `given_name`, `family_name`,
    `date_of_birth`, `country_of_nationality`)
  - `links.creditor` — Creditor ID (required)
  """
  @spec create(Client.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def create(%Client{} = client, params, opts \\ []) do
    Resource.post(client, @base_path, @resource_key, params, opts)
  end

  @doc "Retrieves a single verification detail record by ID."
  @spec get(Client.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def get(%Client{} = client, id, opts \\ []) do
    Resource.get(client, "#{@base_path}/#{id}", @resource_key, opts)
  end

  @doc "Returns a page of verification details. Filter by `:creditor`."
  @spec list(Client.t(), map(), keyword()) ::
          {:ok, %{items: [map()], meta: map()}}
          | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def list(%Client{} = client, params \\ %{}, opts \\ []) do
    Resource.list(client, @base_path, @resource_key, params, opts)
  end

  @doc "Returns a lazy `Stream` over all pages of verification details."
  @spec stream(Client.t(), map(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.stream(client, @base_path, params, @resource_key, opts)
  end

  @doc "Eagerly collects all verification details into a list."
  @spec collect_all(Client.t(), map(), keyword()) ::
          {:ok, [map()]} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def collect_all(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.collect(client, @base_path, params, @resource_key, opts)
  end
end
