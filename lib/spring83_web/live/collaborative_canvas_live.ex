defmodule Spring83Web.CollaborativeCanvasLive do
  use Phoenix.LiveView
  alias Spring83Web.CanvasSharedState
  alias Phoenix.PubSub

  def render(assigns) do
    Spring83Web.PageView.render("collaborative_canvas.html", assigns)
  end

  def mount(_params, _query_params, socket) do
    if connected?(socket) do
      PubSub.subscribe(Spring83.PubSub, "canvas_update_channel")

      tracker_id = Ecto.UUID.generate()
      Phoenix.Tracker.track(:mcTrackerName, self(), :mcTrackerName, tracker_id, %{bueller: "here"})
    end

    {:ok,
     assign(socket, %{
       paint: "blue",
       canvas: CanvasSharedState.get_canvas()
     })}
  end

  def handle_event("set-color-" <> color, _, socket) do
    {:noreply, assign(socket, paint: color)}
  end

  def handle_event("paint-one-cell_" <> location, _, socket) do
    %{paint: paint} = socket.assigns
    {location, _} = Integer.parse(location)

    # Update the shared canvas for new people joining
    CanvasSharedState.set_one_pixel(location, paint)
    # Tell others about the change
    PubSub.broadcast(
      Spring83.PubSub,
      "canvas_update_channel",
      {:canvas_update, %{location: location, paint: paint}}
    )

    {:noreply, socket}
  end

  def handle_info({:canvas_update, %{location: location, paint: paint}}, socket) do
    %{canvas: canvas} = socket.assigns

    # Update our local canvas
    {:noreply,
     assign(socket, canvas: List.update_at(canvas, location, fn _ -> {location, paint} end))}
  end
end
