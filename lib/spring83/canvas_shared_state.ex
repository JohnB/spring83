defmodule Spring83Web.CanvasSharedState do
  use Agent

  @width 16
  @height 16
  @last_cell @width * @height - 1
  @default_canvas 0..@last_cell
                  |> Enum.map(fn n -> {n, ""} end)

  def start_link(options \\ %{}) do
    {:ok, get_pid(options)}
  end

  def get_pid(_options \\ %{}) do
    case(Agent.start_link(fn -> @default_canvas end, name: __MODULE__)) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  # TODO: shift the state to a map and store canvas separate from other values.
  def set_one_pixel(location, paint) do
    Agent.update(get_pid(), fn state ->
      List.update_at(state, location, fn _ -> {location, paint} end)
    end)
  end

  def get_canvas do
    _canvas = Agent.get(get_pid(), fn state -> state end)
  end
end
