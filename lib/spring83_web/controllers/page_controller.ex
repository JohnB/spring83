defmodule Spring83Web.PageController do
  use Spring83Web, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
