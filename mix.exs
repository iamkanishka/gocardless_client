defmodule GoCardlessClient.MixProject do
  use Mix.Project

  @version "1.0.0"
  @source_url "https://github.com/iamkanishka/gocardless_client"
  @description "Production-ready Elixir client for the GoCardlessClient API."

  def project do
    [
      app: :gocardless_client,
      version: @version,
      elixir: "~> 1.18",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      description: @description,
      package: package(),
      deps: deps(),
      docs: docs(),
      aliases: aliases(),
      dialyzer: dialyzer(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.html": :test,
        "coveralls.github": :test
      ],
      name: "GoCardlessClient",
      source_url: @source_url,
      homepage_url: "https://developer.gocardless.com"
    ]
  end

  def application do
    [
      extra_applications: [:logger, :crypto],
      mod: {GoCardlessClient.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:finch, "~> 0.19"},
      {:jason, "~> 1.4"},
      {:plug, "~> 1.15"},
      {:telemetry, "~> 1.2"},
      {:nimble_options, "~> 1.1"},
      {:ex_doc, "~> 0.40", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.18", only: :test},
      {:bypass, "~> 2.1", only: :test},
      {:mox, "~> 1.1", only: :test}
    ]
  end

  defp package do
    [
      name: "gocardless_client",
      maintainers: ["iamkanishka"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "GoCardlessClient API Docs" => "https://developer.gocardless.com/api-reference/",
        "Changelog" => "#{@source_url}/blob/master/CHANGELOG.md"
      },
      files: ~w(lib config mix.exs README.md CHANGELOG.md LICENSE .formatter.exs)
    ]
  end

  defp docs do
    [
      main: "GoCardlessClient",
      source_ref: "v#{@version}",
      source_url: @source_url,
      extras: ["README.md", "CHANGELOG.md"],
      groups_for_modules: [
        Core: [GoCardlessClient, GoCardlessClient.Client, GoCardlessClient.Config],
        "HTTP Layer": [GoCardlessClient.HTTP.Client, GoCardlessClient.HTTP.RateLimiter],
        Resources: [
          GoCardlessClient.Resources.Balances,
          GoCardlessClient.Resources.BankAccountDetails,
          GoCardlessClient.Resources.BankAccountHolderVerifications,
          GoCardlessClient.Resources.BankAuthorisations,
          GoCardlessClient.Resources.BankDetailsLookups,
          GoCardlessClient.Resources.BillingRequestFlows,
          GoCardlessClient.Resources.BillingRequestTemplates,
          GoCardlessClient.Resources.BillingRequests,
          GoCardlessClient.Resources.Blocks,
          GoCardlessClient.Resources.CreditorBankAccounts,
          GoCardlessClient.Resources.Creditors,
          GoCardlessClient.Resources.CurrencyExchangeRates,
          GoCardlessClient.Resources.CustomerBankAccounts,
          GoCardlessClient.Resources.CustomerNotifications,
          GoCardlessClient.Resources.Customers,
          GoCardlessClient.Resources.Events,
          GoCardlessClient.Resources.Exports,
          GoCardlessClient.Resources.FundsAvailabilities,
          GoCardlessClient.Resources.InstalmentSchedules,
          GoCardlessClient.Resources.Institutions,
          GoCardlessClient.Resources.Logos,
          GoCardlessClient.Resources.MandateImportEntries,
          GoCardlessClient.Resources.MandateImports,
          GoCardlessClient.Resources.MandatePDFs,
          GoCardlessClient.Resources.Mandates,
          GoCardlessClient.Resources.NegativeBalanceLimits,
          GoCardlessClient.Resources.OutboundPayments,
          GoCardlessClient.Resources.PayerAuthorisations,
          GoCardlessClient.Resources.PayerThemes,
          GoCardlessClient.Resources.PaymentAccountTransactions,
          GoCardlessClient.Resources.PaymentAccounts,
          GoCardlessClient.Resources.Payments,
          GoCardlessClient.Resources.PayoutItems,
          GoCardlessClient.Resources.Payouts,
          GoCardlessClient.Resources.RedirectFlows,
          GoCardlessClient.Resources.RefundEligibilityIndicators,
          GoCardlessClient.Resources.Refunds,
          GoCardlessClient.Resources.ScenarioSimulators,
          GoCardlessClient.Resources.SchemeIdentifiers,
          GoCardlessClient.Resources.Subscriptions,
          GoCardlessClient.Resources.TaxRates,
          GoCardlessClient.Resources.Transfers,
          GoCardlessClient.Resources.TransferredMandates,
          GoCardlessClient.Resources.VerificationDetails,
          GoCardlessClient.Resources.WebhookResources
        ],
        Webhooks: [GoCardlessClient.Webhooks, GoCardlessClient.Webhooks.Plug],
        OAuth2: [GoCardlessClient.OAuth],
        "Request Signing": [GoCardlessClient.Signing],
        Pagination: [GoCardlessClient.Paginator],
        Errors: [GoCardlessClient.APIError, GoCardlessClient.FieldError, GoCardlessClient.Error]
      ]
    ]
  end

  defp dialyzer do
    [
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
      plt_add_apps: [:ex_unit],
      flags: [:error_handling, :missing_return, :underspecs]
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "compile"],
      quality: ["format --check-formatted", "credo --strict", "dialyzer"],
      "test.all": ["test --cover"]
    ]
  end
end
