defmodule GoCardlessClient.Resources.MandateImports do
  @moduledoc """
  GoCardless Mandate Imports API.

  Used to bulk-import mandates migrated from another payment provider.

  ## Workflow

  1. Create a mandate import: `create/3`
  2. Add individual mandate entries: `GoCardlessClient.Resources.MandateImportEntries.add/3`
  3. Submit the import for processing: `submit/3`
  4. GoCardless processes the import and sends webhooks

  You can `cancel/3` an import at any time before submission.

  ## Example

      {:ok, import} = GoCardlessClient.Resources.MandateImports.create(client, %{
        scheme: "bacs"
      })

      # Add entries...

      {:ok, submitted} = GoCardlessClient.Resources.MandateImports.submit(client, import["id"])
  """

  alias GoCardlessClient.{Client, Resource}

  @resource_key "mandate_imports"
  @base_path "/mandate_imports"

  @doc """
  Creates a new mandate import batch.

  ## Params

  - `:scheme` — target scheme e.g. `"bacs"`, `"sepa_core"` (required)
  """
  @spec create(Client.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def create(%Client{} = client, params, opts \\ []) do
    Resource.post(client, @base_path, @resource_key, params, opts)
  end

  @doc "Retrieves a single mandate import by ID."
  @spec get(Client.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def get(%Client{} = client, id, opts \\ []) do
    Resource.get(client, "#{@base_path}/#{id}", @resource_key, opts)
  end

  @doc "Submits a mandate import for processing. All entries must be added before calling this."
  @spec submit(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def submit(%Client{} = client, id, params \\ %{}, opts \\ []) do
    Resource.action(client, "#{@base_path}/#{id}", "submit", @resource_key, params, opts)
  end

  @doc "Cancels a mandate import. Can only be cancelled before submission."
  @spec cancel(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def cancel(%Client{} = client, id, params \\ %{}, opts \\ []) do
    Resource.action(client, "#{@base_path}/#{id}", "cancel", @resource_key, params, opts)
  end
end
