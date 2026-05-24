defmodule GoCardlessClient.Resources.PayerThemes do
  @moduledoc """
  GoCardless Payer Themes API.

  Custom branding (colours) applied to GoCardless-hosted payment pages
  for a specific creditor. Combine with `GoCardlessClient.Resources.Logos`
  to fully brand the hosted flow.

  ## Example

      {:ok, theme} = GoCardlessClient.Resources.PayerThemes.create(client, %{
        button_background_colour: "#FF5A00",
        content_box_border_colour: "#CCCCCC",
        header_background_colour: "#002244",
        header_text_colour: "#FFFFFF",
        links: %{creditor: "CR123"}
      })
  """

  alias GoCardlessClient.{Client, Resource}

  @resource_key "payer_themes"
  @base_path "/payer_themes"

  @doc """
  Creates a payer theme associated with a creditor.

  ## Params (all colours are hex strings e.g. `"#FF5A00"`)

  - `:button_background_colour` — colour of action buttons
  - `:content_box_border_colour` — border around content boxes
  - `:header_background_colour` — page header background
  - `:header_text_colour` — page header text
  - `links.creditor` — Creditor ID (required)
  """
  @spec create(Client.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def create(%Client{} = client, params, opts \\ []) do
    Resource.post(client, @base_path, @resource_key, params, opts)
  end
end
