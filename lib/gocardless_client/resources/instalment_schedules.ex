defmodule GoCardlessClient.Resources.InstalmentSchedules do
  @moduledoc """
  GoCardless Instalment Schedules API.

  Fixed payment plans that automatically create a series of payments against
  a mandate. Two creation modes are supported:

  - **With dates** — you specify exact charge dates and amounts for each instalment.
  - **With schedule** — you specify an interval and GoCardless calculates the dates.

  ## Example — create with explicit dates

      {:ok, schedule} = GoCardlessClient.Resources.InstalmentSchedules.create_with_dates(
        client,
        %{
          name: "3-month plan",
          currency: "GBP",
          instalments: [
            %{charge_date: "2025-02-01", amount: 5000},
            %{charge_date: "2025-03-01", amount: 5000},
            %{charge_date: "2025-04-01", amount: 5000}
          ],
          links: %{mandate: "MD123"}
        }
      )

  ## Example — create with schedule

      {:ok, schedule} = GoCardlessClient.Resources.InstalmentSchedules.create_with_schedule(
        client,
        %{
          name: "6-month plan",
          currency: "GBP",
          amount: 3000,
          start_date: "2025-02-01",
          count: 6,
          interval_unit: "monthly",
          interval: 1,
          links: %{mandate: "MD123"}
        }
      )
  """

  alias GoCardlessClient.{Client, Paginator, Resource}

  @resource_key "instalment_schedules"
  @base_path "/instalment_schedules"

  @doc """
  Creates an instalment schedule with explicit charge dates.

  ## Params

  - `:name` — schedule name (required)
  - `:currency` — ISO 4217 currency code (required)
  - `:instalments` — list of `%{charge_date: "YYYY-MM-DD", amount: integer}` maps (required)
  - `:total_amount` — must match sum of instalment amounts (optional safety check)
  - `:app_fee` — app fee per payment in minor units (partner integrations)
  - `:metadata` — key-value pairs
  - `links.mandate` — Mandate ID (required)
  """
  @spec create_with_dates(Client.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def create_with_dates(%Client{} = client, params, opts \\ []) do
    Resource.post(client, @base_path, @resource_key, params, opts)
  end

  @doc """
  Creates an instalment schedule from an interval-based recurrence rule.

  ## Params

  - `:name` — schedule name (required)
  - `:currency` — ISO 4217 (required)
  - `:amount` — amount per instalment in minor units (required)
  - `:start_date` — first payment date `"YYYY-MM-DD"` (required)
  - `:count` — total number of payments (required)
  - `:interval_unit` — `"weekly"`, `"monthly"`, or `"yearly"` (required)
  - `:interval` — e.g. `1` for monthly, `2` for bi-monthly (required)
  - `:day_of_month` — day of month for monthly/yearly (optional)
  - `:month` — month for yearly schedules e.g. `"january"` (optional)
  - `:app_fee` — per-payment app fee (partner integrations)
  - `links.mandate` — Mandate ID (required)
  """
  @spec create_with_schedule(Client.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def create_with_schedule(%Client{} = client, params, opts \\ []) do
    Resource.post(client, @base_path, @resource_key, params, opts)
  end

  @doc "Retrieves a single instalment schedule by ID."
  @spec get(Client.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def get(%Client{} = client, id, opts \\ []) do
    Resource.get(client, "#{@base_path}/#{id}", @resource_key, opts)
  end

  @doc """
  Returns a page of instalment schedules.

  Filter by `:mandate`, `:status` (`pending`, `active`, `creation_failed`,
  `completed`, `cancelled`, `errored`).
  """
  @spec list(Client.t(), map(), keyword()) ::
          {:ok, %{items: [map()], meta: map()}}
          | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def list(%Client{} = client, params \\ %{}, opts \\ []) do
    Resource.list(client, @base_path, @resource_key, params, opts)
  end

  @doc "Returns a lazy `Stream` over all pages of instalment schedules."
  @spec stream(Client.t(), map(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.stream(client, @base_path, params, @resource_key, opts)
  end

  @doc "Eagerly collects all instalment schedules into a list."
  @spec collect_all(Client.t(), map(), keyword()) ::
          {:ok, [map()]} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def collect_all(%Client{} = client, params \\ %{}, opts \\ []) do
    Paginator.collect(client, @base_path, params, @resource_key, opts)
  end

  @doc "Updates an instalment schedule. Only `:name` and `:metadata` can be changed."
  @spec update(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def update(%Client{} = client, id, params, opts \\ []) do
    Resource.update(client, "#{@base_path}/#{id}", @resource_key, params, opts)
  end

  @doc "Cancels an instalment schedule and all its pending payments."
  @spec cancel(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def cancel(%Client{} = client, id, params \\ %{}, opts \\ []) do
    Resource.action(client, "#{@base_path}/#{id}", "cancel", @resource_key, params, opts)
  end
end
