defmodule Spring83Web.KenkenView do
  use Spring83Web, :view

  def kenken_board(%{puzzle: %{size: board_size} = puzzle} = assigns) do
    ~H"""
    <div class={"kenken size#{board_size}"}>
      <.full_horizontal_border puzzle={puzzle} />
      <%= for row_number <- 1..board_size do %>
        <.row row_number={row_number} puzzle={puzzle} />
      <% end %>
    </div>
    """
  end

  # Assume the border above this row has already been drawn, so just draw cells
  # intersperced with vertical borders, then add the horizontal borders on the bottom edge.
  def row(%{row_number: row_number, puzzle: %{size: board_size} = puzzle} = assigns) do
    ~H"""
      <.border_segment direction="v" />
      <%= for column <- 1..board_size do %>
        <.cell row_number={row_number} column={column} puzzle={puzzle} />
        <.border_segment direction="v" allow_edits={column < board_size} row_number={row_number} column={column} puzzle={puzzle} />
      <% end %>
      <.intersection />
      <%= for column <- 1..board_size do %>
        <.border_segment direction="h" allow_edits={row_number < board_size} row_number={row_number} column={column} puzzle={puzzle} />
        <.intersection row_number={row_number} column={column} puzzle={puzzle} />
    <% end %>
    """
  end

  def cell(
        %{
          row_number: row_number,
          column: column,
          puzzle: %{cell_values: cell_values, selected: selected, published_at: published_at}
        } = assigns
      ) do
    cell_id = "#{row_number}#{column}"
    # cells are not editable after being published
    maybe_edit = (published_at && %{}) || %{"phx-click" => "edit_cell"}

    # NOTE: for ease of debugging the cell-input CSS, reverse this "if" statement.
    ~H"""
    <%= if selected == cell_id do %>
      <div class="cell">
        <input class="cell-input" style="width: 4.5em;"
          id="cell-editor"
          value={cell_values[cell_id]} type="text" maxlength="7"
          phx-keydown="update_cell"
          phx-blur="cancel_edit_cell"
          phx-hook="AutoFocus"
        />
      </div>
    <% else %>
      <div class="cell" {maybe_edit} phx-value-cell={cell_id}><%= cell_values[cell_id] %></div>
    <% end %>
    """
  end

  def full_horizontal_border(%{puzzle: %{size: board_size}} = assigns) do
    ~H"""
    <.intersection />
    <%= for _column <- 1..board_size do %>
      <.border_segment direction="h" />
      <.intersection />
    <% end %>
    """
  end

  # Blank out the intersection when it doesn't connect to anything
  def intersection(
        %{
          row_number: row_number,
          column: column,
          puzzle: %{borders: borders}
        } = assigns
      ) do
    border_ids = [
      border_id("v", row_number, column),
      border_id("h", row_number, column),
      border_id("v", row_number + 1, column),
      border_id("h", row_number, column + 1)
    ]

    off =
      (Enum.all?(border_ids, fn border_id ->
         (borders[border_id] || "") =~ ~r/off/
       end) && "off") || ""

    ~H"""
    <div class={"intersection #{off}"} ></div>
    """
  end

  def intersection(assigns) do
    ~H"""
    <div class="intersection" ></div>
    """
  end

  def border_segment(
        %{
          direction: direction,
          allow_edits: allow_edits,
          row_number: row_number,
          column: column,
          puzzle: %{size: board_size, borders: borders, published_at: published_at}
        } = assigns
      ) do
    border_id = border_id(direction, row_number, column)
    # Caller has their own reasons to think editing should be allowed,
    # but we also require them to be un-published.
    allow_edits = allow_edits && published_at == nil

    ~H"""
    <div class={"#{direction}-border #{maybe_clickable(allow_edits)} #{borders[border_id]}"}
      {maybe_editable(allow_edits)} phx-value-border={border_id}
    >
    </div>
    """
  end

  def border_segment(%{direction: direction} = assigns) do
    ~H"""
    <div class={"#{direction}-border"} ></div>
    """
  end

  def border_id("v" = direction, row_number, column),
    do: Enum.join([row_number, column, "-", row_number, column + 1])

  def border_id(_direction, row_number, column),
    do: Enum.join([row_number, column, "-", row_number + 1, column])

  def maybe_clickable(true), do: "clickable"
  def maybe_clickable(_), do: ""

  def maybe_editable(true), do: %{"phx-click" => "toggle_border"}
  def maybe_editable(_), do: %{}
end
