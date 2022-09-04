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
    end
    {:ok, assign(socket, %{
      paint: "blue",
      canvas: CanvasSharedState.get_canvas(),
      selected: %{"blue" => "selected"}
    })}
  end

  def handle_event("set-color-red", _, socket) do
    {:noreply, assign(socket, paint: "red", selected: %{"red" => "selected"})}
  end

  def handle_event("set-color-blue", _, socket) do
    {:noreply, assign(socket, paint: "blue", selected: %{"blue" => "selected"})}
  end

  def handle_event("set-color-green", _, socket) do
    {:noreply, assign(socket, paint: "green", selected: %{"green" => "selected"})}
  end

  def handle_event("set-color-yellow", _, socket) do
    {:noreply, assign(socket, paint: "yellow", selected: %{"yellow" => "selected"})}
  end

  def handle_event("set-color-purple", _, socket) do
    {:noreply, assign(socket, paint: "purple", selected: %{"purple" => "selected"})}
  end

  def handle_event("set-color-orange", _, socket) do
    {:noreply, assign(socket, paint: "orange", selected: %{"orange" => "selected"})}
  end

  def handle_event("set-color-white", _, socket) do
    {:noreply, assign(socket, paint: "white", selected: %{"white" => "selected"})}
  end

  def handle_event("paint-one-cell_" <> location, _, socket) do
    %{paint: paint} = socket.assigns
    {location, _} = Integer.parse(location)

    # Update the shared canvas for new people joining
    CanvasSharedState.set_one_pixel(location, paint)
    # Tell others about the change
    PubSub.broadcast(Spring83.PubSub, "canvas_update_channel", {:canvas_update, %{location: location, paint: paint}})

    {:noreply, socket}
  end

  def handle_info({:canvas_update, %{location: location, paint: paint}}, socket) do
    %{canvas: canvas} = socket.assigns

    # Update our local canvas
    {:noreply, assign(socket, canvas: List.update_at(canvas, location, fn _ -> {location, paint} end))}
  end
end
