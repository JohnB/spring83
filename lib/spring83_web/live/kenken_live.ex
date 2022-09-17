defmodule Spring83Web.KenkenLive do
  use Phoenix.LiveView
  alias Spring83.Kenken.Puzzle

  def render(assigns) do
    Spring83Web.KenkenView.render("kenken.html", assigns)
  end

  def mount(params, query_params, socket) do
    puzzle_id = params["puzzle_id"]

    puzzle =
      case puzzle_id do
        nil -> Puzzle.create_puzzle() |> elem(1)
        [id] -> Puzzle.get_puzzle(id)
      end

    {:ok,
     assign(socket, %{
       page_title: "Kenken Creator",
       puzzle: puzzle
     })}
  end

  def handle_event(
        "toggle_border",
        %{"border" => border_id},
        %{assigns: %{puzzle: %{borders: borders} = puzzle}} = socket
      ) do
    updated =
      case borders[border_id] || "" do
        "" -> put_in(borders, [border_id], "off")
        _ -> %{borders | border_id => ""}
      end

    {:noreply,
     assign(socket, %{
       puzzle: %{puzzle | borders: updated}
     })}
  end

  def handle_event("edit_cell", %{"cell" => cell_id}, %{assigns: _assigns} = socket) do
    IO.inspect(cell_id, label: "edit_cell")

    {:noreply, socket}
  end
end
