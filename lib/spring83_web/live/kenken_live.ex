defmodule Spring83Web.KenkenLive do
  use Phoenix.LiveView

  def render(assigns) do
    Spring83Web.PageView.render("kenken.html", assigns)
  end

  def mount(_params, _query_params, socket) do
    {:ok,
      assign(socket, %{
        page_title: "Kenken Creator"
      })}
  end
end
