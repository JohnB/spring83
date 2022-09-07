defmodule Spring83Web.PageController do
  use Spring83Web, :controller

  def index(conn, _params) do
    dates_and_toppings = TodaysPizza.fetch_dates_and_topping()
    render(conn, "index.html", %{dates_and_toppings: dates_and_toppings})
  end

  def send_pizza_message(conn, _params) do
    TodaysPizza.tweet_about_pizza()

    put_flash(conn, :info, "Pizza tweet sent.")
    |> redirect(external: "/")
  end
end
