defmodule Spring83Web.KenkenLive do
  use Phoenix.LiveView
  alias Spring83.Kenken.Puzzle

  # Edit page
  def render(%{puzzle: _puzzle} = assigns) do
    Spring83Web.KenkenView.render("kenken.html", assigns)
  end

  # Index/create page
  def render(_assigns) do
    Spring83Web.KenkenView.render("index.html", %{
      puzzles: [
        %{name: "test puzzle 1", id: 1},
        %{name: "test puzzle 2", id: 2}
      ]
    })
  end

  def handle_params(%{"puzzle_id" => [puzzle_id]} = _params, _uri, socket) do
    puzzle = Puzzle.get_puzzle(puzzle_id)

    {
      :noreply,
      assign(socket, %{
        page_title: "Kenken #{puzzle.id}: #{puzzle.name}",
        puzzle: puzzle
      })
    }
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  # Edit page
  def mount(%{puzzle_id: puzzle_id} = _params, _query_params, socket) do
    {:ok,
     assign(socket, %{
       page_title: "Kenken Creator",
       puzzle: Puzzle.get_puzzle(puzzle_id)
     })}
  end

  # Index/create page
  def mount(_params, _query_params, socket) do
    {:ok, assign(socket, %{page_title: "Kenken Creator"})}
  end

  def handle_event(
        "create_puzzle",
        %{"size" => size},
        socket
      ) do
    {size, _} = Integer.parse(size)

    puzzle = Puzzle.create_puzzle(%{size: size})

    {
      :noreply,
      assign(socket, %{puzzle: puzzle})
      |> push_patch(to: "/kenken/#{puzzle.id}", replace: true)
    }
  end

  def handle_event(
        "publish",
        _attrs,
        %{assigns: %{puzzle: puzzle}} = socket
      ) do
    puzzle =
      Puzzle.update_puzzle(puzzle, %{
        published_at: NaiveDateTime.utc_now(),
        cell_values: puzzle.cell_values,
        borders: puzzle.borders
      })

    {
      :noreply,
      assign(socket, %{puzzle: puzzle})
      |> push_patch(to: "/kenken/#{puzzle.id}", replace: true)
    }
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

    puzzle = Puzzle.update_puzzle(puzzle, %{borders: updated})
    {:noreply, assign(socket, %{puzzle: puzzle})}
  end

  def handle_event("edit_cell", %{"cell" => cell_id}, %{assigns: %{puzzle: puzzle}} = socket) do
    set_selection(puzzle, cell_id, socket)
  end

  def handle_event(
        "save_name",
        %{"value" => new_name} = _params,
        %{assigns: %{puzzle: puzzle}} = socket
      ) do
    puzzle = Puzzle.update_puzzle(puzzle, %{name: new_name})
    {:noreply, assign(socket, %{puzzle: puzzle})}
  end

  # Enter saves the new cell value
  def handle_event(
        "update_cell",
        %{"key" => "Enter", "value" => new_value},
        %{assigns: %{puzzle: %{cell_values: cell_values, selected: selected} = puzzle}} = socket
      ) do
    cell_values = put_in(cell_values, [selected], new_value)
    puzzle = Puzzle.update_puzzle(puzzle, %{cell_values: cell_values})
    clear_selection(puzzle, socket)
  end

  # Escape cancels the edit operation
  def handle_event(
        "update_cell",
        %{"key" => "Escape"},
        %{assigns: %{puzzle: puzzle}} = socket
      ) do
    clear_selection(puzzle, socket)
  end

  # Ignore most key presses
  def handle_event(
        "update_cell",
        _params,
        socket
      ) do
    {:noreply, socket}
  end

  def handle_event(
        "cancel_edit_cell",
        _params,
        %{assigns: %{puzzle: puzzle}} = socket
      ) do
    clear_selection(puzzle, socket)
  end

  def set_selection(puzzle, cell_id, socket) do
    puzzle = Puzzle.update_puzzle(puzzle, %{selected: cell_id})
    {:noreply, assign(socket, %{puzzle: puzzle})}
  end

  def clear_selection(puzzle, socket) do
    puzzle = Puzzle.update_puzzle(puzzle, %{selected: ""})
    {:noreply, assign(socket, %{puzzle: puzzle})}
  end
end
