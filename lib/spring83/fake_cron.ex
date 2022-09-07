defmodule Spring83Web.FakeCron do
  use GenServer
  require Logger

  # Maybe 9ish or 10ish Pacific
  # (the minute is when it was last deployed)
  @utc_tweet_hour 14

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
    delay = time_until_tweet()
    Logger.info("Sending next tweet in #{delay}ms")
    Process.send_after(pid, :send_tweet, delay)
    {:ok, pid}
  end

  @impl true
  def handle_info(:send_tweet, state) do
    Logger.info("handle_info(:send_tweet)")
    maybe_tweet_about_pizza(Mix.env())
    Logger.info("tweet maybe sent")

    Process.send_after(self(), :send_tweet, one_day_ms())
    Logger.info("timer restarted for #{one_day_ms()}ms}")
    {:noreply, state}
  end

  # TODO: rework for prod vs test vs CI vs dev
  def maybe_tweet_about_pizza(:dev = _env) do
    IO.puts("NOT TWEETING FROM :dev ENVIRONMENT")
    Logger.info("NOT TWEETING FROM :dev ENVIRONMENT")
  end

  def maybe_tweet_about_pizza(env) do
    Logger.info("Really sending the tweet for the #{env} environment!")

    # IF ACCIDENTALLY SPAMMING:
    # Disable this line and re-deploy
    TodaysPizza.tweet_about_pizza()
  end

  # we don't care *when* we send it within the hour, so the minutes will be
  # whatever the minutes were when we last deployed.
  def time_until_tweet do
    now = Timex.now()

    cond do
      now.hour < @utc_tweet_hour ->
        @utc_tweet_hour - now.hour

      true ->
        # restorts during the tweet hour will assume its already been sent for the day
        # and schedule tomorrow's
        24 + @utc_tweet_hour - now.hour
    end
    |> hours_to_integer_ms
  end

  def hours_to_integer_ms(hours) do
    hours
    |> Timex.Duration.from_hours()
    |> Timex.Duration.to_milliseconds()
    |> trunc
  end

  def one_day_ms do
    hours_to_integer_ms(24)
  end
end
