import Config

config :gocardless_client,
  access_token: "test_token_sandbox",
  environment: :sandbox,
  max_retries: 0,
  timeout: 5_000
