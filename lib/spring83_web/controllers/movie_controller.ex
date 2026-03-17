defmodule Spring83Web.MovieController do
  use Spring83Web, :controller

  def index(conn, _params) do
    movies = Spring83.TheNewParkwayCache.fetch_movies()
    render(conn, "index.html", %{movies: movies, page_title: "Movies"})
  end
end
