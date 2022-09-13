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
       page_title: "Collaborative Canvas",
       paint: "blue",
       canvas: CanvasSharedState.get_canvas(),
       user_count: CanvasSharedState.get_user_count()
     })}
  end

  # set the current brush color
  def handle_event("set-color-" <> color, _, socket) do
    {:noreply, assign(socket, paint: color)}
  end

  # Update our shared state, and our peers and ourself about a cell being painted.
  def handle_event("paint-one-cell_" <> location, _, %{assigns: %{paint: paint}} = socket) do
    {location, _} = Integer.parse(location)

    # Update the shared canvas for new people joining
    CanvasSharedState.set_one_pixel(location, paint)
    # Tell others about the change
    PubSub.broadcast(
      Spring83.PubSub,
      "canvas_update_channel",
      {:canvas_update, %{location: location, paint: "#{paint} last-click"}}
    )

    {:noreply, socket}
  end

  # Overwrite a cell in the UI with the selected color.
  def handle_info(
        {:canvas_update, %{location: location, paint: paint}},
        %{assigns: %{canvas: canvas}} = socket
      ) do
    # Update our local canvas
    {:noreply,
     assign(socket, canvas: List.update_at(canvas, location, fn _ -> {location, paint} end))}
  end

  def handle_info({:user_count_update}, socket) do
    # Update our local user_count
    {:noreply, assign(socket, user_count: CanvasSharedState.get_user_count())}
  end
end
