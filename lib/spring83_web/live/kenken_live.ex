defmodule Spring83Web.KenkenLive do
  use Phoenix.LiveView
  alias Spring83.Kenken.Puzzle
  require Logger

  # NOTE: these 3 render() functions all use the same route.

  # Edit page for unpublished puzzles
  def render(%{puzzle: %{published_at: nil} = _puzzle} = assigns) do
    Spring83Web.KenkenView.render("kenken.html", assigns)
  end

  # Solving page (when I get to it)
  def render(%{puzzle: _puzzle} = assigns) do
    Spring83Web.KenkenView.render("published.html", assigns)
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
        "unpublish",
        %{"puzzle-id" => puzzle_id},
        %{assigns: %{puzzle: %{published_at: published_at} = puzzle}} = socket
      ) do
    Logger.info("unpublish puzzle #{puzzle_id}, previously published at #{published_at}")
    puzzle = Puzzle.update_puzzle(puzzle, %{published_at: nil})

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

  # Enter saves the new cell value (aka Result)
  def handle_event(
        "update_cell_" <> cell_type,
        %{"key" => "Enter", "value" => new_value},
        %{assigns: %{puzzle: puzzle}} = socket
      ) do
    puzzle = update_cell_attribute(cell_type, new_value, puzzle)
    clear_selection(puzzle, socket)
  end

  # Escape cancels the edit operation
  def handle_event(
        "update_cell_" <> _cell_type,
        %{"key" => "Escape"},
        %{assigns: %{puzzle: puzzle}} = socket
      ) do
    clear_selection(puzzle, socket)
  end

  # Ignore most key presses
  def handle_event(
        "update_cell_" <> _cell_type,
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

  def handle_event(
        "toggle_guess_" <> cell_id_and_guess,
        _params,
        %{assigns: %{puzzle: %{guesses: guesses} = puzzle}} = socket
      ) do
    [cell_id, guess] = String.split(cell_id_and_guess, "_")

    # Older puzzles may not have guesses set.
    guesses = guesses || %{}

    new_value = toggle_guess(guesses[cell_id], guess)
    guesses = put_in(guesses, [cell_id], new_value)
    puzzle = Puzzle.update_puzzle(puzzle, %{guesses: guesses})
    {:noreply, assign(socket, %{puzzle: puzzle})}
  end

  def toggle_guess(nil = guesses, guess), do: [guess]
  def toggle_guess("" = guesses, guess), do: [guess]

  def toggle_guess(guesses, guess) do
    case Enum.member?(guesses, guess) do
      true -> List.delete(guesses, guess)
      _ -> [guess] ++ guesses
    end
  end

  def update_cell_attribute(
        _cell_type = "result",
        new_value,
        %{cell_values: cell_values, selected: selected} = puzzle
      ) do
    cell_values = put_in(cell_values, [selected], new_value)
    Puzzle.update_puzzle(puzzle, %{cell_values: cell_values})
  end

  def update_cell_attribute(
        _cell_type,
        new_value,
        %{answers: answers, selected: selected} = puzzle
      ) do
    # Force a map - older puzzles never set it
    answers = answers || %{}

    answers = put_in(answers, [selected], new_value)
    Puzzle.update_puzzle(puzzle, %{answers: answers})
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
