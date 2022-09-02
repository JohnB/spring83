defmodule Spring83Web.CollaborativeCanvasLive do
  use Phoenix.LiveView

  @width 20
  @height 20
  @last_cell @width * @height - 1
  @default_canvas 0..@last_cell
                  |> Enum.map(fn n -> {n, ""} end)
  @default_state %{
    paint: "blue",
    canvas: @default_canvas,
    selected: %{"blue" => "selected"}
  }

  def render(assigns) do
    Spring83Web.PageView.render("collaborative_canvas.html", assigns)
  end

  def mount(_params, _query_params, socket) do
    {:ok, assign(socket, @default_state)}
  end

  # Centralize canvas updates in an agent, to make it collaborative
  def agent_pid do
    case(Agent.start_link(fn -> @default_canvas end, name: __MODULE__)) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
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

    Agent.update(agent_pid(), fn state ->
      List.update_at(state, location, fn _ -> {location, paint} end)
    end)

    canvas = Agent.get(agent_pid(), fn state -> state end)

    {:noreply,
     assign(socket,
       canvas: canvas
     )}
  end
end
