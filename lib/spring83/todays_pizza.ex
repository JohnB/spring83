defmodule TodaysPizza do
  @moduledoc """
  TodaysPizza keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  require Logger

  @max_length_mastodon 500
  @max_length_blue_sky 300

  def post_pizza_to_mastodon do
    try do
      attempt_to_post_pizza_to_mastodon()
    rescue
      err -> Logger.info("@JohnB - mastodon broke and needed rescuing: #{inspect(err)}}")
    catch
      err -> Logger.info("@JohnB mastodon caught #{inspect(err)}.")
    end
  end

  def post_pizza_to_blue_sky() do
    msg = pizza_message(@max_length_blue_sky)

    Spring83.Bluesky.post(
      "todays-pizza.bsky.social",
      System.get_env("bsky_app_password_for_pizza"),
      msg
    )
  end

  # if it stops sending, try this:
  #   iex -S mix phx.server
  #   TodaysPizza.attempt_to_post_pizza_to_mastodon()
  # and see what exception it throws up
  def attempt_to_post_pizza_to_mastodon do
    conn =
      Hunter.new(
        base_url: "https://sfba.social/",
        bearer_token: System.get_env("mastodon_token")
      )

    Hunter.create_status(conn, pizza_message(@max_length_mastodon))
  end

  def pizza_message_lines do
    pizza_message()
    |> each_line()
  end

  def pizza_message(max_length \\ 500) do
    # NOTE: `h Timex.Format.DateTime.Formatters.Strftime` shows the format codes.
    # Try to match "Fri Jun 27" that we see from the cheeseboard site.
    # The name means: dow=DayOfWeek, mon=Month, day=DayOfMonth
    # Note: the timex formatting allows for "08" or " 8" but not just "8".
    now = Timex.now("America/Los_Angeles")
    yyyymmdd = Timex.format!(now, "{YYYY}{0M}{0D}")
    todays_pizza = Spring83.PizzaCache.pizza_for(yyyymmdd)
    dow_mon_day = Timex.format!(now, "%a %b #{now.day}", :strftime)

    case todays_pizza do
      nil ->
        "#{dow_mon_day}: Sadly, no pizza today.\n\n#{cheeseboard_url()}"

      message when is_binary(message) ->
        String.slice(
          "#{dow_mon_day}: #{trimmed_message(message, max_length, dow_mon_day)}\n\nDetails: #{cheeseboard_url()}",
          0,
          max_length
        )

      _ ->
        "@JohnB Unexpected todays_pizza value: #{inspect(todays_pizza)}."
    end
  end

  def trimmed_message(message, _max_length, _dow_mon_day \\ "") do
    (message == "" && "No data. Probably closed.") || message
  end

  def each_line(msg) do
    msg
    |> String.split("\n", trim: true)
    |> Enum.map(fn line -> String.trim(line) end)
  end

  # TODO: update the return signature to include salad somehow
  # and then restore the salad tweets.
  def fetch_dates_and_topping do
    html = HTTPoison.get!(cheeseboard_url()).body
    {:ok, document} = Floki.parse_document(html)

    pizza_articles = Floki.find(document, ".daily-pizza article")

    hours =
      Floki.find(document, ".chalkboard article")
      |> Enum.reduce(%{}, fn {"article", _, [day | rest]}, acc ->
        hour_data = Enum.map(rest, &Floki.text/1)
        three_char_day = Floki.text(day) |> String.slice(0, 3)
        Map.put(acc, three_char_day, Enum.join(hour_data, "\n"))
      end)

    Enum.map(pizza_articles, fn pizza_article ->
      date = Floki.find(pizza_article, "div.date") |> Floki.text()
      three_char_day = String.slice(date, 0, 3)

      menu = Floki.find(pizza_article, "div.menu")
      [{_, _, elements}] = menu

      topping_and_salad =
        Enum.map(elements, fn element ->
          Floki.text(element)
        end)
        |> Enum.join("\n")

      topping_and_salad = topping_and_salad <> "\n\n" <> (hours[three_char_day] || "")

      [
        date,
        topping_and_salad
      ]
    end)
  end

  def cheeseboard_url do
    "https://cheeseboardcollective.coop/home/pizza/pizza-schedule/"
  end
end
