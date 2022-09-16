defmodule Spring83Web.KenkenLive do
  use Phoenix.LiveView

  def render(assigns) do
    Spring83Web.KenkenView.render("kenken.html", assigns)
  end

  def mount(_params, _query_params, socket) do
    {:ok,
     assign(socket, %{
       page_title: "Kenken Creator"
     })}
  end

  def handle_event("toggle_border", %{"border" => border_id}, %{assigns: _assigns} = socket) do
    IO.inspect(border_id, label: "toggle_border")

    {:noreply, socket}
  end

  def handle_event("edit_cell", %{"cell" => cell_id}, %{assigns: _assigns} = socket) do
    IO.inspect(cell_id, label: "edit_cell")

    {:noreply, socket}
  end
end
