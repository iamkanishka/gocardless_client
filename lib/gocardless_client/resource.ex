defmodule GoCardlessClient.Resource do
  @moduledoc """
  Shared HTTP helpers for GoCardlessClient resource modules.

  GoCardless uses only GET and POST — there is no PUT, PATCH, or DELETE
  (except `DELETE /customers/:id` for GDPR erasure).  All update operations
  use `POST /resource/:id` and all action endpoints use
  `POST /resource/:id/actions/:name`.
  """

  alias GoCardlessClient.{Client, HTTP}

  @type error_response :: {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  @type response :: {:ok, map() | list() | nil} | error_response()
  @type list_response :: {:ok, %{items: [map()], meta: map()}} | error_response()

  @doc "GET a single resource and unwrap its envelope."
  @spec get(Client.t(), String.t(), String.t(), keyword()) :: response()
  def get(%Client{} = client, path, key, opts \\ []) do
    case HTTP.Client.request(client.config, :get, path, opts) do
      {:ok, body} -> {:ok, unwrap(body, key)}
      err -> err
    end
  end

  @doc "GET a list resource; returns `{:ok, %{items: [...], meta: {...}}}`."
  @spec list(Client.t(), String.t(), String.t(), map(), keyword()) :: list_response()
  def list(%Client{} = client, path, key, params \\ %{}, opts \\ []) do
    qs = build_query(params)
    full = if qs == "", do: path, else: "#{path}?#{qs}"

    case HTTP.Client.request(client.config, :get, full, opts) do
      {:ok, body} ->
        {:ok, %{items: Map.get(body || %{}, key, []), meta: Map.get(body || %{}, "meta", %{})}}

      err ->
        err
    end
  end

  @doc """
  POST to create a resource, wrapping params in `%{key => params}`.

  GoCardless wraps both creates and updates in the resource envelope key.
  """
  @spec post(Client.t(), String.t(), String.t(), map(), keyword()) :: response()
  def post(%Client{} = client, path, key, params, opts \\ []) do
    opts = Keyword.put(opts, :body, %{key => params})

    case HTTP.Client.request(client.config, :post, path, opts) do
      {:ok, body} -> {:ok, unwrap(body, key)}
      err -> err
    end
  end

  @doc """
  POST to update a resource (GoCardless uses POST, not PUT/PATCH, for updates).

  Wraps params in `%{key => params}` exactly like `post/5`.
  """
  @spec update(Client.t(), String.t(), String.t(), map(), keyword()) :: response()
  def update(%Client{} = client, path, key, params, opts \\ []) do
    opts = Keyword.put(opts, :body, %{key => params})

    case HTTP.Client.request(client.config, :post, path, opts) do
      {:ok, body} -> {:ok, unwrap(body, key)}
      err -> err
    end
  end

  @doc """
  DELETE a resource.

  Only used for GDPR customer erasure (`DELETE /customers/:id`).
  All other "deletions" in GoCardless are POST actions (cancel, disable, etc.).
  """
  @spec delete(Client.t(), String.t(), String.t(), keyword()) :: response()
  def delete(%Client{} = client, path, key, opts \\ []) do
    case HTTP.Client.request(client.config, :delete, path, opts) do
      {:ok, body} -> {:ok, unwrap(body, key)}
      err -> err
    end
  end

  @doc """
  POST to an action endpoint: `path/actions/name`.

  Wraps params in `%{resource_key => params}` as required by the GoCardless API.
  The envelope key is the resource key (e.g. `"billing_requests"`), NOT `"data"`.
  """
  @spec action(Client.t(), String.t(), String.t(), String.t(), map(), keyword()) :: response()
  def action(%Client{} = client, path, name, key, params, opts \\ []) do
    opts = Keyword.put(opts, :body, %{key => params})

    case HTTP.Client.request(client.config, :post, "#{path}/actions/#{name}", opts) do
      {:ok, body} -> {:ok, unwrap(body, key)}
      err -> err
    end
  end

  @doc "Encodes a map of params into a URL query string, dropping nil values."
  @spec build_query(map()) :: String.t()
  def build_query(p) when p == %{}, do: ""

  def build_query(p) do
    p
    |> Enum.reject(fn {_, v} -> is_nil(v) end)
    |> Enum.map(fn {k, v} -> {to_string(k), to_string(v)} end)
    |> URI.encode_query()
  end

  defp unwrap(nil, _), do: nil
  defp unwrap(body, key) when is_map(body), do: Map.get(body, key, body)
  defp unwrap(body, _), do: body
end
