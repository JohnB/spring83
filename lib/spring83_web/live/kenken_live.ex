defmodule Spring83Web.KenkenLive do
  use Phoenix.LiveView
  alias Spring83.Kenken.Puzzle

  # Edit page
  def render(%{puzzle: _puzzle} = assigns) do
    Spring83Web.KenkenView.render("kenken.html", assigns)
  end

  # Index/create page
  def render(assigns) do
    Spring83Web.KenkenView.render("index.html", %{
      puzzles: [
        %{name: "test puzzle 1", id: 1},
        %{name: "test puzzle 2", id: 2}
      ]
    })
  end

  def handle_params(%{"puzzle_id" => [puzzle_id]} = params, _uri, socket) do
    puzzle = Puzzle.get_puzzle(puzzle_id)

    {
      :noreply,
      assign(socket, %{
        page_title: "Kenken #{puzzle.id}: #{puzzle.name}",
        puzzle: puzzle
      })
    }
  end

  def handle_params(params, _uri, socket) do
    {:noreply, socket}
  end

  # Edit page
  def mount(%{puzzle_id: puzzle_id} = params, _query_params, socket) do
    {:ok,
     assign(socket, %{
       page_title: "Kenken Creator",
       puzzle: Puzzle.get_puzzle(puzzle_id)
     })}
  end

  # Index/create page
  def mount(params, query_params, socket) do
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

  def handle_event("edit_cell", %{"cell" => cell_id}, socket) do
    IO.inspect(cell_id, label: "edit_cell")

    {:noreply, socket}
  end

  def handle_event("save_name", %{"value" => new_name} = _params, %{assigns: %{puzzle: puzzle}} = socket) do
    puzzle = Puzzle.update_puzzle(puzzle, %{name: new_name})
    {:noreply, assign(socket, %{puzzle: puzzle})}
  end
end
