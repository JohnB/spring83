defmodule Spring83.TheNewParkwayCache do
  use Agent
  require Logger

  @month_to_number %{
    "January" => "01",
    "February" => "02",
    "March" => "03",
    "April" => "04",
    "May" => "05",
    "June" => "06",
    "July" => "07",
    "August" => "08",
    "September" => "09",
    "October" => "10",
    "November" => "11",
    "December" => "12"
  }
  @extract_month_and_day ~r/\w+, (?<month>.+) (?<day>.+)/
  @incomplete_day "NOT ALL SHOWINGS ARE LISTED"
  @check_the_date "CHECK THE DATE!"
  @max_length_mastodon 500
  @max_length_blue_sky 300

  def start_link(_) do
    Logger.info("Starting TheNewParkwayCache")
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def get do
    Agent.get(__MODULE__, & &1)
  end

  def fetch_movies() do
    # NOTE: we will have trouble when the calendar spans December to January
    year = DateTime.utc_now().year

    html = HTTPoison.get!(current_calendar_url()).body
    {:ok, document} = Floki.parse_document(html)
    calendar = Floki.find(document, ".tribe-events-loop")
    {_, _, days_and_junk} = List.first(calendar)
    days = Enum.reject(days_and_junk, fn x -> Floki.find(x, "h2") == [] end)
    complete_days = Enum.reject(days, fn day -> Floki.raw_html(day) =~ @incomplete_day end)

    Enum.reduce(complete_days, %{}, fn complete_day, acc ->
      [{_, _, [date]}] = Floki.find(complete_day, "h2")
      %{"day" => day, "month" => month} = Regex.named_captures(@extract_month_and_day, date)

      yyyymmdd = "#{year}#{@month_to_number[month]}#{day}"

      movies =
        Floki.find(complete_day, ".new-parkway-style-list")
        |> Enum.reject(fn one_day -> one_day == [] end)
        |> Enum.reject(fn one_day -> Floki.raw_html(one_day) =~ @check_the_date end)
        |> Enum.reject(fn one_day -> timeless?(one_day) end)
        |> Enum.map(fn one_day ->
          [{_, _, [sktime]}] = Floki.find(one_day, ".sktime")
          [{_, _, [sktitle]}] = Floki.find(one_day, ".sktitle")

          "#{sktime}: #{sktitle}"
        end)
        |> Enum.join("\n")

      Map.put(acc, yyyymmdd, date <> "\n" <> movies)
    end)
  end

  # Actual movies always have a show time.
  # Weird place-holder entries have no time.
  def timeless?(one_day) do
    case Floki.find(one_day, ".sktime") do
      [{_, _, []}] -> true
      [{_, _, [_sktime]}] -> false
    end
  end

  def post_movie_to_mastodon() do
    try do
      attempt_to_post_movie_to_mastodon()
    rescue
      err ->
        Logger.info(
          "@JohnB - MOVIE POSTING to mastodon broke and needed rescuing: #{inspect(err)}}"
        )
    catch
      err -> Logger.info("@JohnB MOVIE POSTING to mastodon caught #{inspect(err)}.")
    end
  end

  def post_movie_to_blue_sky() do
    msg = movie_message(@max_length_blue_sky)

    Spring83.Bluesky.post(
      "new-parkway-bot.bsky.social",
      System.get_env("bsky_app_password_for_movies"),
      msg <> "\n\nDETAILS",
      current_calendar_url()
    )
  end

  # if it stops sending, try this:
  #   iex -S mix phx.server
  #   TodaysPizza.attempt_to_post_movie_to_mastodon()
  # and see what exception it throws up
  def attempt_to_post_movie_to_mastodon() do
    conn =
      Hunter.new(
        base_url: "https://sfba.social/",
        bearer_token: System.get_env("mastodon_token_for_movies")
      )

    Hunter.create_status(
      conn,
      movie_message(@max_length_mastodon) <> "\n\n#{current_calendar_url()}"
    )
  end

  def movie_message(max_length \\ 500) do
    # NOTE: `h Timex.Format.DateTime.Formatters.Strftime` shows the format codes.
    # Try to match "Fri Jun 27" that we see from the cheeseboard site.
    # The name means: dow=DayOfWeek, mon=Month, day=DayOfMonth
    # Note: the timex formatting allows for "08" or " 8" but not just "8".
    now = Timex.now("America/Los_Angeles")
    yyyymmdd = Timex.format!(now, "{YYYY}{0M}{0D}")
    todays_movies = movie_for(yyyymmdd)

    case todays_movies do
      nil ->
        "#{yyyymmdd}: Cannot find today's movies."

      message when is_binary(message) ->
        message
        |> trim_message()
        |> String.slice(
          0,
          max_length
        )

      _ ->
        "@JohnB Unexpected todays_movies value: #{inspect(todays_movies)}."
    end
  end

  def trim_message(msg) do
    msg
    |> String.replace(", classic cartoons & all-you-can-eat cereal", "")
    |> String.replace("UEFA CHAMPIONS LEAGUE FINAL: ", "")
    |> String.replace(" (free on the Mezzanine)", "")
  end

  def movie_for(yyyymmdd) do
    map = get()

    if map[yyyymmdd] do
      map[yyyymmdd]
    else
      latest = fetch_movies()
      Agent.update(__MODULE__, fn x -> Map.merge(x, latest) end)
      latest[yyyymmdd]
    end
  end

  def current_calendar_url do
    the_new_parkway_url() <> "/upcomingevents/calendar/"
  end

  def the_new_parkway_url do
    "https://www.thenewparkway.com"
  end
end
