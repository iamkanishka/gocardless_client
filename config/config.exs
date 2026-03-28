import Config

config :gocardless_client,
  access_token: System.get_env("GOCARDLESS_ACCESS_TOKEN"),
  environment: :sandbox,
  api_version: "2015-07-06",
  timeout: 30_000,
  max_retries: 3,
  base_backoff_ms: 500,
  max_backoff_ms: 30_000,
  pool_size: 10,
  telemetry_prefix: [:gocardless]

import_config "#{config_env()}.exs"
