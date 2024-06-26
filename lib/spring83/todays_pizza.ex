defmodule TodaysPizza do
  @moduledoc """
  TodaysPizza keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  require Logger

  #  @max_length_twitter 278
  @max_length_mastodon 500

  def post_pizza_to_mastodon do
    try do
      attempt_to_post_pizza_to_mastodon()
    rescue
      err -> Logger.info("@JohnB - mastodon broke and needed rescuing: #{inspect(err)}}")
    catch
      err -> Logger.info("@JohnB mastodon caught #{inspect(err)}.")
    end
  end

  # if it stops sending, try this:
  #   fiex
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

  def pizza_message(max_length \\ 278) do
    now = Timex.now("America/Los_Angeles")
    yyyymmdd = Timex.format!(now, "{YYYY}{0M}{0D}")
    todays_pizza = Spring83.PizzaCache.pizza_for(yyyymmdd)
    dow_mon_day = Timex.format!(now, "%a %b #{now.day}", :strftime)

    case todays_pizza do
      nil ->
        "#{dow_mon_day}: Sadly, no pizza today."

      message when is_binary(message) ->
        String.slice(
          "#{dow_mon_day}: #{trimmed_message(message, max_length, dow_mon_day)}",
          0,
          max_length
        )

      _ ->
        "@JohnB Unexpected todays_pizza value: #{inspect(todays_pizza)}."
    end
  end

  # Since the followers all know the drill, just
  # cut to the chase for whatever boilerplate.
  @partial_bake ~r/\*\*\*.*artially baked pizzas .*available at the bakery from 9 a.m. to 4 p.m.( or until we sell out.)?/
  @full_bake ~r/Hot whole and half pizza \(no slices yet\),? .* available at the pizzeria from 5 p\.m\. to 8 p\.m.? or until we sell out/
  @gluten ~r/We have a limited number.*as well/

  def trimmed_message(message, max_length, dow_mon_day \\ "") do
    hot_sellout =
      (String.match?(dow_mon_day, ~r/Sat/) &&
         "\nHot whole or half (no slices): 5-8 (sold out at 7pm on some Saturdays)") ||
        "\nHot whole or half (no slices): 5-8 or until sold out"

    message = Regex.replace(@partial_bake, message, "Partially baked: 9-4 or until sold out.")
    message = Regex.replace(@full_bake, message, hot_sellout)
    message = Regex.replace(@gluten, message, "(some gluten/vegan available)")
    message = Regex.replace(~r/\*\*\*/, message, "\n")
    message = Regex.replace(~r/we sell out/, message, "sold out")
    message = Regex.replace(~r/ and /, message, " & ")
    message = Regex.replace(~r/the /i, message, "")
    message = Regex.replace(~r/is available /i, message, "")
    message = Regex.replace(~r/\(whole, half, slices\) /i, message, "")

    [boilerplate | topping] =
      String.split(message, ~r/\n\n+/, trim: true)
      # Force a period onto every sentence (then remove doubles)
      |> Enum.map(fn line -> line <> "." end)
      |> Enum.map(fn line -> Regex.replace(~r/\.{2,}/i, line, ".") end)

    boilerplate = Regex.replace(~r/Partially baked pizza/i, boilerplate, "Half-baked")

    "#{Enum.join(topping, " ")}\n\n#{boilerplate}"
    # only 280 chars max
    |> String.slice(0, max_length)
  end

  def each_line(msg) do
    msg
    |> String.split("\n", trim: true)
    |> Enum.map(fn line -> String.trim(line) end)
  end

  # TODO: update the return signature to include salad somehow
  # and then restore the salad tweets.
  def fetch_dates_and_topping do
    html = HTTPoison.get!("https://cheeseboardcollective.coop/pizza/").body
    {:ok, document} = Floki.parse_document(html)

    pizza_articles =
      Floki.find(document, ".pizza-list")
      |> Floki.find("article")

    # pizza_article = List.first(pizza_articles)
    Enum.map(pizza_articles, fn pizza_article ->
      date = Floki.find(pizza_article, "div.date") |> Floki.text()
      menu = Floki.find(pizza_article, "div.menu")
      _titles = Floki.find(menu, "h3")
      topping_and_salad = Floki.find(menu, "p")
      topping = topping_and_salad |> List.first() |> Floki.text()
      # salad = topping_and_salad |> List.last |> Floki.text

      [
        date,
        topping
        # salad,
      ]
    end)

    # For offline debugging, comment above and uncomment below.
    # @example_data_20200621
  end

  def cheeseboard_url do
    "https://cheeseboardcollective.coop/pizza/"
  end

  # We likely won't need this static test data very often
  # but I captured it so might as well use it.
  #  @example_data_20200621 [
  #    [
  #      "Tue Jun 23",
  #      "TEST DATA Shiitake mushroom, leek, mozzarella cheese, and sesame-citrus sauce"
  #    ],
  #    [
  #      "Wed Jun 24",
  #      "TEST DATA Artichoke, kalamata olive, fresh ricotta made in Berkeley by Belfiore, mozzarella cheese, and house made tomato sauce"
  #    ],
  #    [
  #      "Thu Jun 25",
  #      "TEST DATA Crushed tomato, red onion, cheddar cheese, mozzarella cheese, garlic olive oil, and cilantro"
  #    ],
  #    [
  #      "Fri Jun 26",
  #      "TEST DATA Peach, Dunbarton blue cheese, mozzarella cheese, and arugula dressed in lemon vinaigrette"
  #    ],
  #    [
  #      "Sat Jun 27",
  #      "TEST DATA A rainbow of mixed sweet bell peppers, red onion, mozzarella cheese, Ossau Iraty cheese, garlic olive oil, and Italian parsley"
  #    ]
  #  ]
end
