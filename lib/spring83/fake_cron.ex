defmodule Spring83Web.FakeCron do
  use GenServer
  require Logger

  def start_link(_options \\ %{}) do
    case(GenServer.start_link(__MODULE__, [], name: __MODULE__)) do
      {:ok, pid} -> set_up_cron(pid)
      {:error, {:already_started, pid}} -> {:ok, pid} |> IO.inspect(label: "already started")
    end
  end

  @impl true
  def init(init_arg) do
    {:ok, init_arg}
  end

  def set_up_cron(pid) do
    Logger.info("set_up_cron")
    # TODO: send_after needs an integer, and time_until_tweet() returns 5.4e7
    #    Process.send_after(pid, :send_tweet, time_until_tweet())
    {:ok, pid}
  end

  @impl true
  def handle_info(:send_tweet, state) do
    Logger.info("handle_info(:send_tweet, #{state})")
    TodaysPizza.tweet_about_pizza()
    Logger.info("tweet maybe sent")
    {:noreply, state}
  end

  @utc_tweet_hour 16

  def time_until_tweet do
    now = Timex.now()

    cond do
      now.hour == @utc_tweet_hour ->
        0

      now.hour < @utc_tweet_hour ->
        Timex.Duration.to_milliseconds(Timex.Duration.from_hours(@utc_tweet_hour - now.hour))

      true ->
        Timex.Duration.to_milliseconds(Timex.Duration.from_hours(24 + @utc_tweet_hour - now.hour))
    end
  end
end
