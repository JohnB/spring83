defmodule Spring83Web.CanvasSharedState do
  use GenServer
  require Logger
  alias Spring83.Canvas

  @width 16
  @height 16
  @last_cell @width * @height - 1
  @default_canvas Enum.map(0..@last_cell, fn n -> {n, ""} end)
  @autosave_timeout :timer.seconds(20)

  # Client

  def start_link(_options \\ %{}) do
    pid =
      case(GenServer.start_link(__MODULE__, %{}, name: {:global, __MODULE__})) do
        {:ok, pid} -> pid
        {:error, {:already_started, _pid}} -> raise("CanvasSharedState started twice?")
      end

    {:ok, pid}
  end

  def set_one_pixel(location, paint) do
    GenServer.cast(get_pid(), {:set_one_pixel, location, paint})
  end

  def get_canvas do
    GenServer.call(get_pid(), :get_canvas)
  end

  def set_user_count(delta) do
    GenServer.cast(get_pid(), {:set_user_count, delta})
  end

  def get_user_count do
    GenServer.call(get_pid(), :get_user_count)
  end

  # Server

  @impl true
  def init(_) do
    canvas = Canvas.latest() || @default_canvas

    {:ok,
     %{
       canvas: canvas,
       user_count: 0,
       autosave_pid: nil
     }}
  end

  def get_pid(_options \\ %{}) do
    case(GenServer.start_link(__MODULE__, %{}, name: {:global, __MODULE__})) do
      {:ok, pid} ->
        raise("CanvasSharedState should have been started already (pid #{inspect(pid)}})")

      {:error, {:already_started, pid}} ->
        pid
    end
  end

  @impl true
  def handle_call(:get_canvas, _from, %{canvas: canvas} = state) do
    {:reply, canvas, state}
  end

  @impl true
  def handle_call(:get_user_count, _from, %{user_count: user_count} = state) do
    {:reply, user_count, state}
  end

  # TODO: rename to :update_user_count
  @impl true
  def handle_cast(
        {:set_user_count, delta},
        %{user_count: user_count} = state
      ) do
    {:noreply,
     %{
       state
       | user_count: Enum.max([user_count + delta, 0])
     }}
  end

  @impl true
  def handle_cast(
        {:set_one_pixel, location, paint},
        %{canvas: canvas, autosave_pid: autosave_pid} = state
      ) do
    # Reset our auto-save timer to be 2 minutes after this most-recent change
    autosave_pid && Process.cancel_timer(autosave_pid)
    autosave_pid = Process.send_after(self(), :save_canvas, @autosave_timeout)

    {:noreply,
     %{
       state
       | canvas: List.update_at(canvas, location, fn _ -> {location, paint} end),
         autosave_pid: autosave_pid
     }}
  end

  @impl true
  def handle_info(:save_canvas, %{canvas: canvas} = state) do
    Canvas.save(canvas)
    Logger.info("Canvas saved")

    {:noreply, state}
  end
end
