defmodule Spring83Web.PageController do
  use Spring83Web, :controller

  def index(conn, _params) do
    dates_and_toppings = TodaysPizza.fetch_dates_and_topping()
    render(conn, "index.html", %{dates_and_toppings: dates_and_toppings})
  end

  def cal_greek(conn, _params) do
    events = Spring83.VenueCache.venue_list(:cal_greek)
    render(conn, "who_is_at_the.html", %{events: events})
  end

  def la_greek(conn, _params) do
    events = Spring83.VenueCache.venue_list(:la_greek)
    render(conn, "who_is_at_the.html", %{events: events})
  end
end
