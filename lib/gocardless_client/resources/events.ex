defmodule GoCardlessClient.Resources.Events do
  @moduledoc """
  GoCardless Events API.

  An immutable, append-only audit log of everything that happens in the system.
  Events are the basis for webhook payloads and are used for reconciling payouts.

  ## Event structure

      %{
        "id" => "EV123",
        "created_at" => "2025-01-15T10:30:00.000Z",
        "action" => "paid_out",
        "resource_type" => "payments",
        "links" => %{"payment" => "PM123", "payout" => "PO456"},
        "details" => %{
          "origin" => "gocardless",
          "cause" => "payment_paid_out",
          "description" => "Payment paid out by GoCardless"
        },
        "metadata" => %{}
      }

  ## Example — reconcile a payout

      {:ok, %{items: events}} = GoCardlessClient.Resources.Events.list(client, %{
        "payout" => "PO123"
      })
  """

  alias GoCardlessClient.{Client, Paginator, Resource}

  @resource_key "events"
  @base_path "/events"

  @doc """
  Returns a page of events with optional filters.

  ## Filter params

  - `:action` — e.g. `"paid_out"`, `"failed"`, `"active"`
  - `:resource_type` — `"payments"`, `"mandates"`, `"payouts"`, `"refunds"`,
    `"subscriptions"`, `"billing_requests"`
  - `:payment` — filter by payment ID
  - `:mandate` — filter by mandate ID
  - `:subscription` — filter by subscription ID
  - `:refund` — filter by refund ID
  - `:payout` — filter by payout ID
  - `:billing_request` — filter by billing request ID
  - `:created_at[gte]` / `:created_at[lte]` — date range filters
  """
  @spec list(Client.t(), map(), keyword()) ::
          {:ok, %{items: [map()], meta: map()}}
          | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def list(%Client{} = client, params \\ %{}, opts \\ []) do
    Resource.list(client, @base_path, @resource_key, params, opts)
  end

  @doc "Returns a lazy `Stream` over all pages of events."
  @spec stream(Client.t(), map(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.stream(client, @base_path, params, @resource_key, opts)
  end

  @doc "Eagerly collects all events into a list. Use `stream/3` for large datasets."
  @spec collect_all(Client.t(), map(), keyword()) ::
          {:ok, [map()]} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def collect_all(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.collect(client, @base_path, params, @resource_key, opts)
  end

  @doc "Retrieves a single event by ID."
  @spec get(Client.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def get(%Client{} = client, id, opts \\ []) do
    Resource.get(client, "#{@base_path}/#{id}", @resource_key, opts)
  end
end
