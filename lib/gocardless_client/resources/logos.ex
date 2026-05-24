defmodule GoCardlessClient.Resources.Logos do
  @moduledoc """
  GoCardless Logos API.

  Upload a logo image associated with a creditor. The logo appears on
  GoCardless-hosted payment pages for that creditor.

  ## Example

      pem_data = File.read!("logo.png") |> Base.encode64()

      {:ok, logo} = GoCardlessClient.Resources.Logos.create(client, %{
        image: pem_data,
        links: %{creditor: "CR123"}
      })
  """

  alias GoCardlessClient.{Client, Resource}

  @resource_key "logos"
  @base_path "/logos"

  @doc """
  Uploads a logo and associates it with a creditor.

  ## Params

  - `:image` — Base64-encoded image data (PNG, JPG, or SVG; min 400×400px recommended)
  - `links.creditor` — Creditor ID (required)
  """
  @spec create(Client.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def create(%Client{} = client, params, opts \\ []) do
    Resource.post(client, @base_path, @resource_key, params, opts)
  end
end
