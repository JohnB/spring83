defmodule Spring83Web.PageController do
  use Spring83Web, :controller

  require Logger

  def index(conn, _params) do
    log_referer(conn, "PageController.index")
    dates_and_toppings = TodaysPizza.fetch_dates_and_topping()
    render(conn, "index.html", %{dates_and_toppings: dates_and_toppings})
  end

  def cal_greek(conn, _params) do
    log_referer(conn, "PageController.cal_greek")
    Logger.info("conn.host: #{conn.host}}")

    past_present_future =
      Spring83.VenueCache.venue_list(:cal_greek)
      |> split_into_past_present_future()

    render(
      conn,
      "who_is_at_the.html",
      put_in(past_present_future, [:page_title], "Cal Berkeley Greek Theater")
    )
  end

  def la_greek(conn, _params) do
    log_referer(conn, "PageController.la_greek")

    past_present_future =
      Spring83.VenueCache.venue_list(:la_greek)
      |> split_into_past_present_future()

    render(
      conn,
      "who_is_at_the.html",
      put_in(past_present_future, [:page_title], "LA Greek Theater")
    )
  end

  defp log_referer(conn, caller) do
    referer = List.keyfind(conn.req_headers, "referer", 0, {"", "no referer"}) |> elem(1)
    Logger.info("#{caller} referer=#{referer}}")
  end

  defp split_into_past_present_future(map) do
    today = Venue.today_yyyymmdd()
    event_dates = Map.keys(map.events) |> Enum.sort()

    Enum.reduce(event_dates, %{past: [], present: [], future: [], events: map}, fn yyyymmdd,
                                                                                   acc ->
      case {yyyymmdd == today, yyyymmdd < today} do
        {false, true} -> %{acc | past: acc.past ++ [yyyymmdd]}
        {true, false} -> %{acc | present: acc.present ++ [yyyymmdd]}
        {false, false} -> %{acc | future: acc.future ++ [yyyymmdd]}
      end
    end)
  end
end
