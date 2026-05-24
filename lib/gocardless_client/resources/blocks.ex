defmodule GoCardlessClient.Resources.Blocks do
  @moduledoc """
  GoCardless Blocks API.

  Fraud prevention mechanism to block specific customers, email addresses,
  bank accounts, or device fingerprints from creating new mandates.

  ## Block types

  - `"email"` — block a specific email address
  - `"email_domain"` — block an entire email domain
  - `"device_fingerprint"` — block by device fingerprint
  - `"bank_account"` — block a specific bank account

  ## Example

      {:ok, block} = GoCardlessClient.Resources.Blocks.create(client, %{
        block_type: "email",
        reason_type: "fraud",
        resource_reference: "fraudster@example.com"
      })
  """

  alias GoCardlessClient.{Client, Paginator, Resource}

  @resource_key "blocks"
  @base_path "/blocks"

  @doc """
  Creates a block.

  ## Params

  - `:block_type` — `"email"`, `"email_domain"`, `"device_fingerprint"`, or `"bank_account"` (required)
  - `:reason_type` — `"fraud"` or `"other"` (required)
  - `:resource_reference` — the value to block (required)
  - `:reason_description` — human-readable reason (optional)
  """
  @spec create(Client.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def create(%Client{} = client, params, opts \\ []) do
    Resource.post(client, @base_path, @resource_key, params, opts)
  end

  @doc "Retrieves a single block by ID."
  @spec get(Client.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def get(%Client{} = client, id, opts \\ []) do
    Resource.get(client, "#{@base_path}/#{id}", @resource_key, opts)
  end

  @doc "Returns a page of blocks. Filter by `:block_type`, `:reason_type`, `:created_at[gte]`."
  @spec list(Client.t(), map(), keyword()) ::
          {:ok, %{items: [map()], meta: map()}}
          | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def list(%Client{} = client, params \\ %{}, opts \\ []) do
    Resource.list(client, @base_path, @resource_key, params, opts)
  end

  @doc "Returns a lazy `Stream` over all pages of blocks."
  @spec stream(Client.t(), map(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.stream(client, @base_path, params, @resource_key, opts)
  end

  @doc "Eagerly collects all blocks into a list."
  @spec collect_all(Client.t(), map(), keyword()) ::
          {:ok, [map()]} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def collect_all(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.collect(client, @base_path, params, @resource_key, opts)
  end

  @doc "Disables a block, stopping it from preventing mandate creation."
  @spec disable(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def disable(%Client{} = client, id, params \\ %{}, opts \\ []) do
    Resource.action(client, "#{@base_path}/#{id}", "disable", @resource_key, params, opts)
  end

  @doc "Re-enables a previously disabled block."
  @spec enable(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def enable(%Client{} = client, id, params \\ %{}, opts \\ []) do
    Resource.action(client, "#{@base_path}/#{id}", "enable", @resource_key, params, opts)
  end

  @doc """
  Creates blocks by reference — blocks all accounts linked to an existing resource.

  For example, you can block all bank accounts and email addresses linked to
  a mandate or payment that was used fraudulently.

  ## Params

  - `:reference_type` — `"mandate"`, `"payment"`, `"customer"` (required)
  - `:reference_id` — ID of the reference resource (required)
  - `:reason_type` — `"fraud"` or `"other"` (required)
  - `:reason_description` — optional human-readable reason
  """
  @spec block_by_reference(Client.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def block_by_reference(%Client{} = client, params, opts \\ []) do
    Resource.post(client, "#{@base_path}/block_by_reference", @resource_key, params, opts)
  end
end
