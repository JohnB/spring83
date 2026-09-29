defmodule Spring83Web.PentominoController do
  use Spring83Web, :controller

  def index(conn, _params) do
    render(conn, "index.html", %{page_title: "Pentominos!"})
  end
end
