defmodule Spring83Web.MovieController do
  use Spring83Web, :controller

  def index(conn, _params) do
    date_limit = Spring83.TheNewParkwayCache.date_limit_yyyymmddhhmmss()

    movies =
      Spring83.TheNewParkwayCache.fetch_movies()
      |> Map.to_list()
      |> Enum.reject(fn {yyyymmdd, _m} -> yyyymmdd > date_limit end)
      |> Enum.sort(fn {yyyymmdd1, _m1}, {yyyymmdd2, _m2} -> yyyymmdd1 < yyyymmdd2 end)

    render(conn, "index.html", %{movies: movies, page_title: "Movies"})
  end
end
