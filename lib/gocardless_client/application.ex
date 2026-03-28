defmodule GoCardlessClient.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    GoCardlessClient.HTTP.RateLimiter.init()
    pool_size = Application.get_env(:gocardless_client, :pool_size, 10)
    finch_name = Application.get_env(:gocardless_client, :finch_name, GoCardlessClient.Finch)

    children = [
      {Finch,
       name: finch_name,
       pools: %{
         "https://api-sandbox.gocardless.com" => [size: pool_size],
         "https://api.gocardless.com" => [size: pool_size],
         "https://connect-sandbox.gocardless.com" => [size: 2],
         "https://connect.gocardless.com" => [size: 2]
       }}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: GoCardlessClient.Supervisor)
  end
end
