defmodule Spring83Web.Tracker do
  use Phoenix.Tracker

  def start_link(opts) do
    IO.inspect(opts, label: "\n\nTracker.start_link opts")

    Phoenix.Tracker.start_link(__MODULE__, opts, opts)
  end

  def init(opts) do
    IO.inspect(opts, label: "\n\nTracker.init opts")
    server = Keyword.fetch!(opts, :pubsub_server)
             |> IO.inspect(label: "pubsub_server")

    {:ok, %{pubsub_server: server, node_name: Phoenix.PubSub.node_name(server)}}
    |> IO.inspect(label: "\n\nTracker.init")
  end

  def handle_diff(diff, state) do
    for {topic, {joins, leaves}} <- diff do
      IO.inspect(topic, label: "handle_diff(#{Enum.count(joins)},#{Enum.count(leaves)})")
    end

    {:ok, state}
  end
end
