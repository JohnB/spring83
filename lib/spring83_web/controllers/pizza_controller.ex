defmodule Spring83Web.PizzaController do
  use Spring83Web, :controller

  def index(conn, _params) do
    dates_and_toppings = TodaysPizza.fetch_dates_and_topping()
    render(conn, "index.html", %{dates_and_toppings: dates_and_toppings, page_title: "Pizzas"})
  end
end
