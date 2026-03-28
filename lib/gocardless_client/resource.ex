defmodule GoCardlessClient.Resource do
  @moduledoc "Shared HTTP helpers for GoCardlessClient resource modules."

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

  @doc "POST creating a resource, wrapping params in `%{key => params}`."
  @spec post(Client.t(), String.t(), String.t(), map(), keyword()) :: response()
  def post(%Client{} = client, path, key, params, opts \\ []) do
    opts = Keyword.put(opts, :body, %{key => params})

    case HTTP.Client.request(client.config, :post, path, opts) do
      {:ok, body} -> {:ok, unwrap(body, key)}
      err -> err
    end
  end

  @doc "PUT updating a resource."
  @spec put(Client.t(), String.t(), String.t(), map(), keyword()) :: response()
  def put(%Client{} = client, path, key, params, opts \\ []) do
    opts = Keyword.put(opts, :body, %{key => params})

    case HTTP.Client.request(client.config, :put, path, opts) do
      {:ok, body} -> {:ok, unwrap(body, key)}
      err -> err
    end
  end

  @doc "DELETE a resource."
  @spec delete(Client.t(), String.t(), String.t(), keyword()) :: response()
  def delete(%Client{} = client, path, key, opts \\ []) do
    case HTTP.Client.request(client.config, :delete, path, opts) do
      {:ok, body} -> {:ok, unwrap(body, key)}
      err -> err
    end
  end

  @doc "POST to an action endpoint: `path/actions/name` wrapping params in `%{data: params}`."
  @spec action(Client.t(), String.t(), String.t(), String.t(), map(), keyword()) :: response()
  def action(%Client{} = client, path, name, key, params, opts \\ []) do
    opts = Keyword.put(opts, :body, %{"data" => params})

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
