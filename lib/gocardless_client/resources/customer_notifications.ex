defmodule GoCardlessClient.Resources.CustomerNotifications do
  @moduledoc """
  GoCardless Customer Notifications API.

  Allows you to mark a customer notification as handled when you are managing
  notifications yourself (rather than letting GoCardless send them automatically).

  This is used in custom notification flows. When you handle a notification
  yourself (e.g. send your own branded email), you call `handle/3` to signal
  GoCardless that it should not send a duplicate notification.

  ## Example

      # In your notification handler:
      def send_mandate_confirmation(notification_id) do
        # Send your own branded email to the customer...
        send_mandate_email()

        # Then tell GoCardless you've handled it
        {:ok, _} = GoCardlessClient.Resources.CustomerNotifications.handle(
          client,
          notification_id
        )
      end
  """

  alias GoCardlessClient.{Client, Resource}

  @resource_key "customer_notifications"
  @base_path "/customer_notifications"

  @doc """
  Marks a customer notification as handled by you.

  After calling this, GoCardless will not send its own notification for this event.
  """
  @spec handle(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, GoCardlessClient.APIError.t() | GoCardlessClient.Error.t()}
  def handle(%Client{} = client, id, params \\ %{}, opts \\ []) do
    Resource.action(client, "#{@base_path}/#{id}", "handle", @resource_key, params, opts)
  end
end
