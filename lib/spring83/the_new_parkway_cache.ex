defmodule Spring83.TheNewParkwayCache do
  use Agent
  require Jason
  require Logger
  require Timex

  @time_horizon_in_days 7
  @details "\n\nDETAILS"
  @max_length_mastodon 500
  @max_length_blue_sky 300 - String.length(@details)
  @default_state %{}
  @hashtags "\n#oakland #movie"

  def start_link(_) do
    Logger.info("Starting TheNewParkwayCache")
    Agent.start_link(fn -> @default_state end, name: __MODULE__)
  end

  def get do
    Agent.get(__MODULE__, & &1)
  end

  def clear() do
    Agent.update(__MODULE__, fn _previous_cache -> @default_state end)
  end

  # This query comes from the following process:
  # - in the Network tab of a browser, use "Copy as cURL" to get the raw curl command
  # - use https://curlconverter.com/elixir/ to format the curl command and convert to an HTTPoison call
  # - verify it runs successfully from the command line
  # - remove "session_id" and other excess cruft, but keep "site-id"
  # - verify it still works
  # - paste the HTTPoison call here
  # - strip out excess junk in the "variables" section
  # - verify it still works
  def raw_graphql_movie_list() do
    Logger.info("Fetching raw graphql movie list")
    response =
      HTTPoison.post!(
        "https://thenewparkway.com/graphql",
        "{\"variables\":{\"searchString\":\"\",\"type\":\"now-playing-and-coming-soon\",\"subtype\":\"watched\",\"orderBy\":\"date_of_first_showing\",\"descending\":false,\"limit\":1000,\"titleClassId\":null,\"titleClassIds\":[],\"siteIds\":[],\"currentMovieId\":null,\"movieIdsToExclude\":null},\"extensions\":{\"clientLibrary\":{\"name\":\"@apollo/client\",\"version\":\"4.0.9\"}},\"query\":\"query ($limit: Int, $orderBy: String, $descending: Boolean, $searchString: String, $siteIds: [ID], $currentMovieId: ID, $movieIdsToExclude: [ID], $titleClassId: ID, $titleClassIds: [ID], $type: String, $subtype: String) {\\n  movies(\\n    limit: $limit\\n    orderBy: $orderBy\\n    descending: $descending\\n    searchString: $searchString\\n    siteIds: $siteIds\\n    currentMovieId: $currentMovieId\\n    movieIdsToExclude: $movieIdsToExclude\\n    titleClassId: $titleClassId\\n    titleClassIds: $titleClassIds\\n    type: $type\\n    subtype: $subtype\\n  ) {\\n    data {\\n      id\\n      name\\n      urlSlug\\n      searchTerms\\n      dcmEdiMovieId\\n      dcmEdiMovieName\\n      datesWithPublicShowing\\n      __typename\\n    }\\n    count\\n    resultVersion\\n    __typename\\n  }\\n}\"}",
        [
          {"accept", "application/graphql-response+json,application/json;q=0.9"},
          {"accept-language", "en-US,en;q=0.9"},
          {"cache-control", "no-cache"},
          {"client-type", "consumer"},
          {"content-type", "application/json"},
          {"is-electron-mode", "false"},
          {"origin", "https://thenewparkway.com"},
          {"pragma", "no-cache"},
          {"referer", "https://thenewparkway.com/upcoming-events/"},
          {"sec-ch-ua",
           "\"Not=A?Brand\";v=\"99\", \"Google Chrome\";v=\"151\", \"Chromium\";v=\"151\""},
          {"sec-ch-ua-mobile", "?0"},
          {"sec-ch-ua-platform", "\"macOS\""},
          {"sec-fetch-dest", "empty"},
          {"sec-fetch-mode", "cors"},
          {"sec-fetch-site", "same-origin"},
          {"site-id", "383"},
          {"user-agent",
           "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36"}
        ]
      )

    {:ok, json} = Jason.decode(response.body)
    movies = json["data"]["movies"]["data"]
    Logger.info("Fetched up to #{Enum.count(movies)} movies")
    movies
  end

  def date_limit_yyyymmddhhmmss() do
    {:ok, formatted_date} =
      DateTime.utc_now()
      |> DateTime.add(@time_horizon_in_days, :day)
      |> Timex.format("%Y%0m%0d%H%M", :strftime)

    formatted_date
  end

  def fetch_graphql_movie_list() do
    movies = raw_graphql_movie_list()

    date_limit = date_limit_yyyymmddhhmmss()

    #    IO.inspect(Enum.take(movies, 10), label: "movies")
    #    IO.inspect(date_limit, label: "date_limit")

    movies
    |> Enum.map(fn movie ->
      near_future_dates =
        movie["datesWithPublicShowing"]
        |> Enum.map(fn date_string ->
          {:ok, date} = Date.from_iso8601(date_string)
          {:ok, yyyymmdd} = Timex.format(date, "%Y%0m%0d", :strftime)
          %{yyyymmdd: yyyymmdd, sort_by: yyyymmdd}
        end)
        |> Enum.reject(&(&1.yyyymmdd > date_limit))

      %{
        id: movie["id"],
        datesWithPublicShowing: near_future_dates,
        name: movie["name"],
        urlSlug: movie["urlSlug"]
      }
    end)
    |> Enum.reject(&(&1.datesWithPublicShowing == []))

    #    |> IO.inspect(label: "movieS")
  end

  # See creation process for fetch_graphql_movie_list/0
  def fetch_graphql_movie_times(movieId) do
    # TODO: figure out what params to send for a particular movie and date
    response =
      HTTPoison.post!(
        "https://thenewparkway.com/graphql",
        "{\"variables\":{\"ids\":[],\"movieId\":\"#{movieId}\",\"movieIds\":[],\"titleClassId\":null,\"titleClassIds\":null,\"siteIds\":[],\"anyShowingBadgeIds\":null,\"everyShowingBadgeIds\":[null],\"resultVersion\":null},\"extensions\":{\"clientLibrary\":{\"name\":\"@apollo/client\",\"version\":\"4.0.9\"}},\"query\":\"query ($date: String, $ids: [ID], $movieId: ID, $movieIds: [ID], $titleClassId: ID, $titleClassIds: [ID], $siteIds: [ID], $everyShowingBadgeIds: [ID], $anyShowingBadgeIds: [ID], $resultVersion: String) {\\n  showingsForDate(\\n    date: $date\\n    ids: $ids\\n    movieId: $movieId\\n    movieIds: $movieIds\\n    titleClassId: $titleClassId\\n    titleClassIds: $titleClassIds\\n    siteIds: $siteIds\\n    everyShowingBadgeIds: $everyShowingBadgeIds\\n    anyShowingBadgeIds: $anyShowingBadgeIds\\n    resultVersion: $resultVersion\\n  ) {\\n    data {\\n      id\\n      time\\n      showingId\\n      isMarathon\\n      hasMarathon\\n      allowSalesInMarathon\\n      overrideSeatChart\\n      hasSeatChart\\n      overridePriceCard\\n      overridePostStartTimeBufferMinutes\\n      customPostStartTimeBufferMinutes\\n      published\\n      ticketsSold\\n      marathonTicketsSold\\n      ticketsPaid\\n      current\\n      past\\n      overrideReservedSeating\\n      overrideReservedSeatingValue\\n      customHeldSeatCount\\n      overrideHeldSeatCount\\n      customMarathonSeatCount\\n      overrideMarathonSeatCount\\n      overrideShowingBadges\\n      allowWithoutMembership\\n      disableTheaterSeatDelivery\\n      qrItemOrderingOnly\\n      allowConsumerRefunds\\n      allowConsumerQrTabWithoutPaymentMethod\\n      allowItemOrdersOnline\\n      private\\n      isPreview\\n      displayMetaData\\n      overrideMaxTicketsPerOrderPerShowing\\n      maxTicketsPerOrderPerShowing\\n      screenId\\n      originalScreenId\\n      priceCardId\\n      customPriceCardId\\n      movie {\\n        id\\n        name\\n        abbreviation\\n        showingStatus\\n        displayMetaData\\n        urlSlug\\n        posterImage\\n        signageDisplayPoster\\n        bannerImage\\n        signageDisplayBanner\\n        animatedPosterVideo\\n        signageDisplayAnimatedPoster\\n        signageMessageOverride\\n        color\\n        synopsis\\n        starring\\n        writers\\n        directedBy\\n        producedBy\\n        searchTerms\\n        duration\\n        genre\\n        allGenres\\n        countryOfOrigin\\n        originalLanguage\\n        rating\\n        ratingReason\\n        trailerYoutubeId\\n        trailerVideo\\n        signageDisplayTrailer\\n        releaseDate\\n        dateOfFirstShowing\\n        overrideDateOfFirstShowing\\n        hideDateOfFirstShowing\\n        boxOfficeWeekStartDay\\n        boxOfficeWeekExtendPremieres\\n        embargoShowingLiftedAt\\n        embargoPurchaseLiftedAt\\n        allowPrivateSalesOnExternal\\n        isMarathon\\n        predictedWeekOneTicketSales\\n        tmdbPopularityScore\\n        tmdbId\\n        includeInComingSoon\\n        includeInFuture\\n        overridePriceCard\\n        overridePostStartTimeBufferMinutes\\n        customPostStartTimeBufferMinutes\\n        sendRentrak\\n        rentrakName\\n        libraryChildrenShowingCount\\n        showingCount\\n        allowPastSales\\n        dcmEdiMovieId\\n        dcmEdiMovieName\\n        disableOnlineConcessions\\n        overrideMaxTicketsPerOrderPerShowing\\n        maxTicketsPerOrderPerShowing\\n        displayOrder\\n        displayOrderNext\\n        taxExempt\\n        rottenTomatoesOverwrite\\n        showRottenTomatoesRating\\n        siteId\\n        titleClassId\\n        customPriceCardId\\n        criticScore\\n        criticRating\\n        audienceScore\\n        audienceRating\\n        __typename\\n      }\\n      showing {\\n        id\\n        time\\n        showingId\\n        isMarathon\\n        hasMarathon\\n        allowSalesInMarathon\\n        overrideSeatChart\\n        hasSeatChart\\n        overridePriceCard\\n        overridePostStartTimeBufferMinutes\\n        customPostStartTimeBufferMinutes\\n        published\\n        ticketsSold\\n        marathonTicketsSold\\n        ticketsPaid\\n        current\\n        past\\n        overrideReservedSeating\\n        overrideReservedSeatingValue\\n        customHeldSeatCount\\n        overrideHeldSeatCount\\n        customMarathonSeatCount\\n        overrideMarathonSeatCount\\n        overrideShowingBadges\\n        allowWithoutMembership\\n        disableTheaterSeatDelivery\\n        qrItemOrderingOnly\\n        allowConsumerRefunds\\n        allowConsumerQrTabWithoutPaymentMethod\\n        allowItemOrdersOnline\\n        private\\n        isPreview\\n        displayMetaData\\n        overrideMaxTicketsPerOrderPerShowing\\n        maxTicketsPerOrderPerShowing\\n        screenId\\n        originalScreenId\\n        priceCardId\\n        customPriceCardId\\n        movie {\\n          id\\n          name\\n          abbreviation\\n          showingStatus\\n          displayMetaData\\n          urlSlug\\n          posterImage\\n          signageDisplayPoster\\n          bannerImage\\n          signageDisplayBanner\\n          animatedPosterVideo\\n          signageDisplayAnimatedPoster\\n          signageMessageOverride\\n          color\\n          synopsis\\n          starring\\n          writers\\n          directedBy\\n          producedBy\\n          searchTerms\\n          duration\\n          genre\\n          allGenres\\n          countryOfOrigin\\n          originalLanguage\\n          rating\\n          ratingReason\\n          trailerYoutubeId\\n          trailerVideo\\n          signageDisplayTrailer\\n          releaseDate\\n          dateOfFirstShowing\\n          overrideDateOfFirstShowing\\n          hideDateOfFirstShowing\\n          boxOfficeWeekStartDay\\n          boxOfficeWeekExtendPremieres\\n          embargoShowingLiftedAt\\n          embargoPurchaseLiftedAt\\n          allowPrivateSalesOnExternal\\n          isMarathon\\n          predictedWeekOneTicketSales\\n          tmdbPopularityScore\\n          tmdbId\\n          includeInComingSoon\\n          includeInFuture\\n          overridePriceCard\\n          overridePostStartTimeBufferMinutes\\n          customPostStartTimeBufferMinutes\\n          sendRentrak\\n          rentrakName\\n          libraryChildrenShowingCount\\n          showingCount\\n          allowPastSales\\n          dcmEdiMovieId\\n          dcmEdiMovieName\\n          disableOnlineConcessions\\n          overrideMaxTicketsPerOrderPerShowing\\n          maxTicketsPerOrderPerShowing\\n          displayOrder\\n          displayOrderNext\\n          taxExempt\\n          rottenTomatoesOverwrite\\n          showRottenTomatoesRating\\n          siteId\\n          titleClassId\\n          customPriceCardId\\n          __typename\\n        }\\n        seatsRemaining\\n        seatsRemainingWithoutSocialDistancing\\n        __typename\\n      }\\n      showings {\\n        id\\n        time\\n        showingId\\n        isMarathon\\n        hasMarathon\\n        allowSalesInMarathon\\n        overrideSeatChart\\n        hasSeatChart\\n        overridePriceCard\\n        overridePostStartTimeBufferMinutes\\n        customPostStartTimeBufferMinutes\\n        published\\n        ticketsSold\\n        marathonTicketsSold\\n        ticketsPaid\\n        current\\n        past\\n        overrideReservedSeating\\n        overrideReservedSeatingValue\\n        customHeldSeatCount\\n        overrideHeldSeatCount\\n        customMarathonSeatCount\\n        overrideMarathonSeatCount\\n        overrideShowingBadges\\n        allowWithoutMembership\\n        disableTheaterSeatDelivery\\n        qrItemOrderingOnly\\n        allowConsumerRefunds\\n        allowConsumerQrTabWithoutPaymentMethod\\n        allowItemOrdersOnline\\n        private\\n        isPreview\\n        displayMetaData\\n        overrideMaxTicketsPerOrderPerShowing\\n        maxTicketsPerOrderPerShowing\\n        screenId\\n        originalScreenId\\n        priceCardId\\n        customPriceCardId\\n        movie {\\n          id\\n          name\\n          abbreviation\\n          showingStatus\\n          displayMetaData\\n          urlSlug\\n          posterImage\\n          signageDisplayPoster\\n          bannerImage\\n          signageDisplayBanner\\n          animatedPosterVideo\\n          signageDisplayAnimatedPoster\\n          signageMessageOverride\\n          color\\n          synopsis\\n          starring\\n          writers\\n          directedBy\\n          producedBy\\n          searchTerms\\n          duration\\n          genre\\n          allGenres\\n          countryOfOrigin\\n          originalLanguage\\n          rating\\n          ratingReason\\n          trailerYoutubeId\\n          trailerVideo\\n          signageDisplayTrailer\\n          releaseDate\\n          dateOfFirstShowing\\n          overrideDateOfFirstShowing\\n          hideDateOfFirstShowing\\n          boxOfficeWeekStartDay\\n          boxOfficeWeekExtendPremieres\\n          embargoShowingLiftedAt\\n          embargoPurchaseLiftedAt\\n          allowPrivateSalesOnExternal\\n          isMarathon\\n          predictedWeekOneTicketSales\\n          tmdbPopularityScore\\n          tmdbId\\n          includeInComingSoon\\n          includeInFuture\\n          overridePriceCard\\n          overridePostStartTimeBufferMinutes\\n          customPostStartTimeBufferMinutes\\n          sendRentrak\\n          rentrakName\\n          libraryChildrenShowingCount\\n          showingCount\\n          allowPastSales\\n          dcmEdiMovieId\\n          dcmEdiMovieName\\n          disableOnlineConcessions\\n          overrideMaxTicketsPerOrderPerShowing\\n          maxTicketsPerOrderPerShowing\\n          displayOrder\\n          displayOrderNext\\n          taxExempt\\n          rottenTomatoesOverwrite\\n          showRottenTomatoesRating\\n          siteId\\n          titleClassId\\n          customPriceCardId\\n          __typename\\n        }\\n        seatsRemaining\\n        seatsRemainingWithoutSocialDistancing\\n        __typename\\n      }\\n      showingBadgeIds\\n      predictedAttendance\\n      seatsRemaining\\n      seatsRemainingWithoutSocialDistancing\\n      __typename\\n    }\\n    count\\n    resultVersion\\n    __typename\\n  }\\n}\"}",
        [
          {"accept", "application/graphql-response+json,application/json;q=0.9"},
          {"accept-language", "en-US,en;q=0.9"},
          {"cache-control", "no-cache"},
          {"circuit-id", "166"},
          {"client-type", "consumer"},
          {"content-type", "application/json"},
          {"is-electron-mode", "false"},
          {"origin", "https://thenewparkway.com"},
          {"pragma", "no-cache"},
          {"priority", "u=1, i"},
          {"referer", "https://thenewparkway.com/"},
          {"sec-ch-ua",
           "\"Not=A?Brand\";v=\"99\", \"Google Chrome\";v=\"151\", \"Chromium\";v=\"151\""},
          {"sec-ch-ua-mobile", "?0"},
          {"sec-ch-ua-platform", "\"macOS\""},
          {"sec-fetch-dest", "empty"},
          {"sec-fetch-mode", "cors"},
          {"sec-fetch-site", "same-origin"},
          {"site-id", "383"},
          {"user-agent",
           "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36"}
        ]
      )

    {:ok, json} = Jason.decode(response.body)
    gmt_datetimes = json["data"]["showingsForDate"]["data"] |> Enum.map(fn m -> m["time"] end)

    Enum.map(gmt_datetimes, fn gmt_datetime_string ->
      {:ok, gmt_datetime, _} = DateTime.from_iso8601(gmt_datetime_string)
      {:ok, pacific_datetime} = DateTime.shift_zone(gmt_datetime, "America/Los_Angeles")
      {:ok, yyyymmdd} = Timex.format(pacific_datetime, "%Y%0m%0d", :strftime)
      {:ok, time} = Timex.format(pacific_datetime, "%l:%M%P", :strftime)
      {:ok, sort_by} = Timex.format(pacific_datetime, "%Y%0m%0d%H%M", :strftime)
      %{yyyymmdd: yyyymmdd, time: time, sort_by: sort_by}
    end)
    |> Enum.sort_by(& &1.sort_by)
  end

  def fetch_movies() do
    movies = fetch_graphql_movie_list()

    movies
    |> Enum.reduce(%{}, fn movie, acc ->
      dates_and_times = fetch_graphql_movie_times(movie.id)

      dates_and_times
      |> Enum.reduce(acc, fn date_and_time, acc2 ->
        {_, fresh} =
          get_and_update_in(acc2, [date_and_time.yyyymmdd], fn current_value ->
            updated =
              put_in(current_value || %{}, [date_and_time.sort_by <> movie.name], %{
                name: movie.name,
                time: date_and_time.time,
                urlSlug: movie.urlSlug
              })

            # |> IO.inspect()
            {current_value, updated}
          end)

        fresh
      end)
    end)
    |> Enum.reduce(%{}, fn {yyyymmdd, movie_hashs}, acc ->
      mm = String.slice(yyyymmdd, 4, 2)
      dd = String.slice(yyyymmdd, 6, 2)
      date = "#{mm}/#{dd}"

      movies =
        Enum.sort_by(movie_hashs, fn {k, _v} -> k end)
        |> Enum.map(fn {_k, v} ->
          "#{v.time}: #{v.name}"
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
    message = movie_message(@max_length_blue_sky)

    Spring83.Bluesky.post(
      "new-parkway-bot.bsky.social",
      System.get_env("bsky_app_password_for_movies"),
      message <> @details,
      current_calendar_url()
    )
  end

  # if it stops sending, try this:
  #   iex -S mix phx.server
  #   Spring83.TheNewParkwayCache.attempt_to_post_movie_to_mastodon()
  # and see what exception it throws up
  def attempt_to_post_movie_to_mastodon() do
    conn =
      Hunter.new(
        base_url: "https://sfba.social/",
        bearer_token: System.get_env("mastodon_token_for_movies")
      )

    Hunter.create_status(
      conn,
      movie_message(@max_length_mastodon) <> @hashtags <> "\n\n#{current_calendar_url()}",
      visibility: :public
    )
  end

  def movie_message(max_length \\ @max_length_mastodon) do
    # NOTE: `h Timex.Format.DateTime.Formatters.Strftime` shows the format codes.
    # Try to match "Fri Jun 27" that we see from the New Parkway site.
    # The name means: dow=DayOfWeek, mon=Month, day=DayOfMonth
    # Note: the timex formatting allows for "08" or " 8" but not just "8".
    now = Timex.now("America/Los_Angeles")
    |> IO.inspect(label: "before formatting to yyyymmdd")
    yyyymmdd = Timex.format!(now, "{YYYY}{0M}{0D}")
    |> IO.inspect(label: "yyyymmdd")
    todays_movies = movie_for(yyyymmdd)

    case todays_movies do
      nil ->
        "#{yyyymmdd}: Cannot find today's movies."

      message when is_binary(message) ->
        message
        |> trim_message(max_length)
        |> String.slice(
          0,
          max_length
        )

      _ ->
        "@JohnB Unexpected todays_movies value: #{inspect(todays_movies)}."
    end
  end

  def too_long?(message, max_length), do: String.length(message) > max_length

  def trim_message(message, max_length) do
    message
    |> String.replace(", classic cartoons & all-you-can-eat cereal", "", global: true)
    |> String.replace("UEFA CHAMPIONS LEAGUE FINAL: ", "", global: true)
    |> String.replace("SUPER SMASH BROS MELEE ON THE MEZZ", "SMASH BROS ", global: true)
    |> String.replace("(free on the Mezzanine)", "(free)", global: true)
    |> String.replace("2026 OSCAR NOMINATED SHORT FILMS", "OSCAR SHORTS", global: true)
    |> String.replace(" AT THE NEW PARKWAY", "", global: true)
    |> trim_if_too_long(max_length, ~r/ THE /, " ")
    |> trim_if_too_long(max_length, " A ", " ")
    |> trim_if_too_long(max_length, ",", "")
  end

  def trim_if_too_long(message, max_length, search_for, replace_with) do
    if too_long?(message, max_length) do
      String.replace(message, search_for, replace_with, global: true)
    else
      message
    end
  end

  def movie_for(yyyymmdd) do
    map = get()

    if map[yyyymmdd] do
      map[yyyymmdd]
    else
      latest = fetch_movies()
      Agent.update(__MODULE__, fn previous_cache -> Map.merge(previous_cache, latest) end)
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
