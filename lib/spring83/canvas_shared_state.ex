defmodule Spring83Web.CanvasSharedState do
  use Agent

  @width 16
  @height 16
  @last_cell @width * @height - 1
  @default_canvas 0..@last_cell
                  |> Enum.map(fn n -> {n, ""} end)
  @default_state %{
    canvas: @default_canvas,
    user_count: 0
  }

  def start_link(options \\ %{}) do
    {:ok, get_pid(options)}
  end

  def get_pid(_options \\ %{}) do
    case(Agent.start_link(fn -> @default_state end, name: __MODULE__)) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  def set_one_pixel(location, paint) do
    Agent.update(get_pid(), fn state = %{canvas: canvas} = state ->
      %{state | canvas: List.update_at(canvas, location, fn _ -> {location, paint} end)}
    end)
  end

  def get_canvas do
    %{canvas: canvas} = Agent.get(get_pid(), fn state -> state end)
    canvas
  end

  def set_user_count(delta) do
    Agent.update(get_pid(), fn state = %{user_count: user_count} = state ->
      user_count = Enum.max([user_count + delta, 0])
      %{state | user_count: user_count}
    end)
  end

  def get_user_count do
    %{user_count: user_count} = Agent.get(get_pid(), fn state -> state end)
    user_count
  end
end
