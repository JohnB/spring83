#
# Consider replacing this crap with https://hexdocs.pm/quantum/readme.html
#
defmodule Spring83Web.FakeCron do
  use GenServer
  require Logger
  alias Mix

  # Maybe 9ish or 10ish Pacific
  # (the minute is when it was last deployed)
  @utc_tweet_hour 15

  # Mix.env doesn't exist in the prod runtime???
  @mix_env Mix.env()

  def start_link(_options \\ %{}) do
    Logger.info("FakeCron Mix env is #{@mix_env} !!!")

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
    delay = time_until_toot()
    Logger.info("Sending next toot to mastodon in #{delay}ms")
    Process.send_after(pid, :send_toot, delay)
    {:ok, pid}
  end

  #  def crap() do
  #    raise("UGH!")
  #  end

  def attempt(log_msg, what_to_attempt) do
    Logger.info("Attempting #{log_msg}")
    try do
      what_to_attempt.()
    rescue
      err -> Logger.info("Failed to #{log_msg}: #{inspect(err)}}")
    end
  end

  @impl true
  def handle_info(:send_toot, state) do
    Process.send_after(self(), :send_toot, one_day_ms())
    Logger.info("timer restarted for #{one_day_ms()}ms}")

    Logger.info("handle_info(:send_toot)")
    attempt("post_pizza_to_mastodon", &TodaysPizza.post_pizza_to_mastodon/0)
    attempt("post_pizza_to_blue_sky", &TodaysPizza.post_pizza_to_blue_sky/0)
    attempt("post_movie_to_mastodon", &Spring83.TheNewParkwayCache.post_movie_to_mastodon/0)
    attempt("post_movie_to_blue_sky", &Spring83.TheNewParkwayCache.post_movie_to_blue_sky/0)
    Logger.info("FINISHED handle_info(:send_toot)")

    {:noreply, state}
  end

  # we don't care *when* we send it within the hour, so the minutes will be
  # whatever the minutes were when we last deployed.
  def time_until_toot do
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
