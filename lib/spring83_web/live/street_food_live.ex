defmodule Spring83Web.StreetFoodLive do
  use Phoenix.LiveView
  require Logger

  @raw_street_food File.read!("./lib/spring83/rqzj-sfat.json")

  def render(_assigns) do
    Spring83Web.StreetFoodView.render("street_food.html", %{
      approved_street_foods: approved_street_foods() |> Enum.take(10)
    })
  end

  def mount(_params, _query_params, socket) do
    {:ok, assign(socket, %{page_title: "Kenken Creator"})}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def approved_street_foods(raw_list \\ @raw_street_food) do
    {:ok, decoded} = Jason.decode(raw_list)

    decoded
      |> Enum.reject(fn truck -> truck["latitude"] == "0" || truck["status"] != "APPROVED" end)
  end
end