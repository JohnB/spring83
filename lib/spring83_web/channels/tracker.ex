defmodule Spring83Web.Tracker do
  use Phoenix.Tracker
  alias Spring83Web.CanvasSharedState
  alias Phoenix.PubSub

  def start_link(opts) do
    Phoenix.Tracker.start_link(__MODULE__, opts, opts)
  end

  def init(opts) do
    server = Keyword.fetch!(opts, :pubsub_server)

    {:ok, %{pubsub_server: server, node_name: Phoenix.PubSub.node_name(server)}}
  end

  def handle_diff(diff, state) do
    for {_topic, {joins, leaves}} <- diff do
      delta = Enum.count(joins) - Enum.count(leaves)
      # Persist the change
      CanvasSharedState.set_user_count(delta)

      # Tell others about the change
      PubSub.broadcast(
        Spring83.PubSub,
        "canvas_update_channel",
        {:user_count_update}
      )
    end

    {:ok, state}
  end
end
