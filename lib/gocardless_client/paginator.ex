defmodule GoCardlessClient.Paginator do
  @moduledoc """
  Cursor-based pagination for GoCardlessClient list endpoints.

  Returns a lazy `Stream` that automatically fetches additional pages as items
  are consumed. No extra memory is allocated until items are pulled.

  ## Example

      # Stream all paid-out payments lazily
      GoCardlessClient.Resources.Payments.stream(client, %{status: "paid_out"})
      |> Stream.each(&reconcile/1)
      |> Stream.run()

      # Collect all customers into a list
      {:ok, customers} = GoCardlessClient.Paginator.collect(client, "/customers", %{}, "customers")
  """

  alias GoCardlessClient.{Client, HTTP}

  @type page_item :: map()

  @doc """
  Returns a lazy `Stream` over all pages of a GoCardlessClient list endpoint.

  - `client`       — a `GoCardlessClient.Client` struct
  - `path`         — API path e.g. `"/payments"`
  - `params`       — initial query params as a map
  - `resource_key` — JSON key holding the list e.g. `"payments"`
  - `opts`         — per-request options (`:idempotency_key`, `:request_id`, etc.)
  """
  @spec stream(Client.t(), String.t(), map(), String.t(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, path, params, resource_key, opts \\ []) do
    Stream.resource(
      fn -> {params, true} end,
      &fetch_page(client, path, resource_key, opts, &1),
      fn _ -> :ok end
    )
  end

  @doc """
  Eagerly collects all pages into a list.

  Returns `{:ok, [item]}` or `{:error, reason}` if any page fetch fails.
  """
  @spec collect(Client.t(), String.t(), map(), String.t(), keyword()) ::
          {:ok, [page_item()]}
          | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def collect(%Client{} = client, path, params, resource_key, opts \\ []) do
    client
    |> stream(path, params, resource_key, opts)
    |> reduce_stream()
  end

  # ── Private ──────────────────────────────────────────────────────────────

  # Stream.resource/3 step function — returns {items, next_state} or {:halt, state}.
  defp fetch_page(_client, _path, _resource_key, _opts, {_params, false}) do
    {:halt, nil}
  end

  defp fetch_page(client, path, resource_key, opts, {params, true}) do
    full_path = build_path(path, params)

    case HTTP.Client.request(client.config, :get, full_path, opts) do
      {:ok, body} ->
        process_page(body, resource_key, params)

      {:error, _} = err ->
        # Surface error as a single item so callers can detect it via pattern match
        {[err], {params, false}}
    end
  end

  defp process_page(body, resource_key, params) when is_map(body) do
    items = Map.get(body, resource_key, [])
    after_cursor = get_in(body, ["meta", "cursors", "after"])
    next_state = next_pagination_state(params, after_cursor)
    {items, next_state}
  end

  defp process_page(_body, _resource_key, params) do
    {[], {params, false}}
  end

  defp next_pagination_state(params, after_cursor)
       when is_binary(after_cursor) and after_cursor != "" do
    {Map.put(params, "after", after_cursor), true}
  end

  defp next_pagination_state(params, _after_cursor) do
    {params, false}
  end

  defp build_path(path, params) when map_size(params) == 0, do: path

  defp build_path(path, params) do
    query = URI.encode_query(params)
    "#{path}?#{query}"
  end

  defp reduce_stream(stream) do
    result =
      Enum.reduce_while(stream, {:ok, []}, fn
        {:error, _} = err, _acc -> {:halt, err}
        item, {:ok, acc} -> {:cont, {:ok, [item | acc]}}
      end)

    case result do
      {:ok, items} -> {:ok, Enum.reverse(items)}
      {:error, _} = err -> err
    end
  end
end
