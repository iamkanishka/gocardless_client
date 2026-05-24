defmodule GoCardlessClient.Resources.Exports do
  @moduledoc """
  GoCardless Exports API.

  Pre-generated data exports (CSV format) triggered from the GoCardless Dashboard.
  Poll or use webhooks to detect when an export is ready, then download via `download_url`.

  ## Export statuses

  - `initialising` — export is being queued
  - `queued` — waiting to be processed
  - `processing` — being generated
  - `ready` — available for download at `download_url`
  - `failed` — generation failed

  ## Example

      {:ok, export} = GoCardlessClient.Resources.Exports.get(client, "EX123")
      if export["status"] == "ready" do
        # download from export["download_url"]
      end
  """

  alias GoCardlessClient.{Client, Paginator, Resource}

  @resource_key "exports"
  @base_path "/exports"

  @doc "Retrieves a single export by ID."
  @spec get(Client.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def get(%Client{} = client, id, opts \\ []) do
    Resource.get(client, "#{@base_path}/#{id}", @resource_key, opts)
  end

  @doc "Returns a page of exports."
  @spec list(Client.t(), map(), keyword()) ::
          {:ok, %{items: [map()], meta: map()}}
          | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def list(%Client{} = client, params \\ %{}, opts \\ []) do
    Resource.list(client, @base_path, @resource_key, params, opts)
  end

  @doc "Returns a lazy `Stream` over all pages of exports."
  @spec stream(Client.t(), map(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.stream(client, @base_path, params, @resource_key, opts)
  end

  @doc "Eagerly collects all exports into a list."
  @spec collect_all(Client.t(), map(), keyword()) ::
          {:ok, [map()]} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def collect_all(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.collect(client, @base_path, params, @resource_key, opts)
  end
end
