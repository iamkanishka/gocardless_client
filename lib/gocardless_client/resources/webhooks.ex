defmodule GoCardlessClient.Resources.Webhooks do
  @moduledoc """
  GoCardless Webhooks API.

  Provides access to the webhook delivery log — the record of every webhook
  GoCardless has attempted to deliver to your endpoint. Use this to inspect
  failed deliveries and retry them.

  For webhook signature verification and event parsing, use the
  `GoCardlessClient.Webhooks` module instead.

  ## Example — retry a failed delivery

      {:ok, %{items: webhooks}} = GoCardlessClient.Resources.Webhooks.list(client, %{
        successful: false
      })

      Enum.each(webhooks, fn wh ->
        {:ok, _} = GoCardlessClient.Resources.Webhooks.retry(client, wh["id"])
      end)
  """

  alias GoCardlessClient.{Client, Paginator, Resource}

  @resource_key "webhooks"
  @base_path "/webhooks"

  @doc "Retrieves a single webhook delivery record by ID."
  @spec get(Client.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def get(%Client{} = client, id, opts \\ []) do
    Resource.get(client, "#{@base_path}/#{id}", @resource_key, opts)
  end

  @doc """
  Returns a page of webhook delivery records.

  Filter by `:created_at[gte]`, `:created_at[lte]`, `:is_test`.
  """
  @spec list(Client.t(), map(), keyword()) ::
          {:ok, %{items: [map()], meta: map()}}
          | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def list(%Client{} = client, params \\ %{}, opts \\ []) do
    Resource.list(client, @base_path, @resource_key, params, opts)
  end

  @doc "Returns a lazy `Stream` over all pages of webhook delivery records."
  @spec stream(Client.t(), map(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.stream(client, @base_path, params, @resource_key, opts)
  end

  @doc "Eagerly collects all webhook delivery records into a list."
  @spec collect_all(Client.t(), map(), keyword()) ::
          {:ok, [map()]} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def collect_all(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.collect(client, @base_path, params, @resource_key, opts)
  end

  @doc "Retries delivery of a webhook to your endpoint."
  @spec retry(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def retry(%Client{} = client, id, params \\ %{}, opts \\ []) do
    Resource.action(client, "#{@base_path}/#{id}", "retry", @resource_key, params, opts)
  end
end
