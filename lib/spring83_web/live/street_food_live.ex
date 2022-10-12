defmodule Spring83Web.StreetFoodLive do
  use Phoenix.LiveView
  require Logger
  alias Spring83.FoodTruck

  # This file originally downloaded from https://data.sfgov.org/resource/rqzj-sfat.json
  # and eventually replaced with a weekly cache of the latest data.
  @raw_street_food File.read!("./lib/spring83/rqzj-sfat.json")

  @union_square %{latitude: 37.78795, longitude: -122.4075}

  def render(_assigns) do
    Spring83Web.StreetFoodView.render("street_food.html", %{
      approved_street_foods: nearby_street_food(@union_square, 5000),
      maybe_japanese_foods: maybe_japanese_foods(@union_square),
      locationdescription: "Union Square",
      location: @union_square
    })
  end

  def mount(_params, _query_params, socket) do
    {:ok, assign(socket, %{page_title: "SF Street Food"})}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  defp maybe_japanese_foods(user_location) do
    approved_street_foods()
    |> Enum.sort_by(&distance_squared(&1, user_location))
    |> Enum.filter(&FoodTruck.maybe_japanese?/1)
  end

  defp nearby_street_food(user_location, limit) do
    approved_street_foods()
    |> Enum.sort_by(&distance_squared(&1, user_location))
    |> Enum.take(limit)
  end

  # For comparison sake - such as used by `sort_by` - using the
  # distance squared is equivalent to sorting by the distance
  # and saves us from having to take the square root.
  defp distance_squared(
         %{latitude: lat1, longitude: lon1} = _location1,
         %{latitude: lat2, longitude: lon2} = _location2
       ),
       do: Float.pow(lat1 - lat2, 2) * Float.pow(lon1 - lon2, 2)

  defp approved_street_foods(raw_list \\ @raw_street_food) do
    {:ok, decoded} = Jason.decode(raw_list)

    decoded
    |> Enum.map(fn parsed_json -> FoodTruck.from_json(parsed_json) end)
    |> Enum.filter(fn truck -> FoodTruck.plausible_location?(truck) end)
    |> Enum.filter(fn truck -> FoodTruck.approved?(truck) end)
  end
end
