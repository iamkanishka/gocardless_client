defmodule GoCardlessClient.Client do
  @moduledoc """
  GoCardlessClient API client struct. Build with `new/1` or `new!/1`.

  ## Quick start

      client = GoCardlessClient.Client.new!(access_token: "tok", environment: :sandbox)
      {:ok, cust} = GoCardlessClient.Resources.Customers.create(client, %{email: "a@b.com"})
  """

  alias GoCardlessClient.Config

  @type t :: %__MODULE__{config: Config.t()}
  @enforce_keys [:config]
  defstruct [:config]

  @doc "Creates a client; returns `{:ok, t()}` or `{:error, %NimbleOptions.ValidationError{}}`."
  @spec new(keyword()) :: {:ok, t()} | {:error, NimbleOptions.ValidationError.t()}
  def new(opts \\ []) do
    case Config.new(opts) do
      {:ok, config} -> {:ok, %__MODULE__{config: config}}
      err -> err
    end
  end

  @doc "Like `new/1` but raises `ArgumentError` on bad options."
  @spec new!(keyword()) :: t()
  def new!(opts \\ []), do: %__MODULE__{config: Config.new!(opts)}

  @doc "Returns the current rate-limit state observed from API responses."
  @spec rate_limit_state(t()) :: map()
  def rate_limit_state(%__MODULE__{config: config}),
    do: GoCardlessClient.HTTP.RateLimiter.get(config)

  @doc "Returns a new client with a different access token (per-merchant OAuth flows)."
  @spec with_token(t(), String.t()) :: t()
  def with_token(%__MODULE__{config: config} = c, token),
    do: %{c | config: %{config | access_token: token}}
end
