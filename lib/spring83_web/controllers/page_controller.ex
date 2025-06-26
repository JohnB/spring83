defmodule Spring83Web.PageController do
  use Spring83Web, :controller

  require Logger

  def index(conn, _params) do
    render(conn, "index.html", %{
      page_title: "JohnB Random Code"
    })
  end

  def cal_greek(conn, _params) do
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
    past_present_future =
      Spring83.VenueCache.venue_list(:la_greek)
      |> split_into_past_present_future()

    render(
      conn,
      "who_is_at_the.html",
      put_in(past_present_future, [:page_title], "LA Greek Theater")
    )
  end

  # Unused as of 2025/6/6 (fe09f27)
  #  defp log_referer(conn, caller) do
  #    referer = List.keyfind(conn.req_headers, "referer", 0, {"", "no referer"}) |> elem(1)
  #    Logger.info("#{caller} referer=#{referer}}")
  #  end

  def split_into_past_present_future(map) do
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
