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

  def row(%{row_number: row_number, puzzle: %{size: board_size} = puzzle} = assigns) do
    ~H"""
      <.vertical_border_segment />
      <%= for column <- 1..board_size do %>
        <.cell row_number={row_number} column={column} puzzle={puzzle} />
        <.vertical_border_segment row_number={row_number} column={column} puzzle={puzzle} />
      <% end %>
      <.intersection />
      <%= for column <- 1..board_size do %>
        <.horizontal_border_segment row_number={row_number} column={column} puzzle={puzzle} />
        <.intersection />
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
      <.horizontal_border_segment />
      <.intersection />
    <% end %>
    """
  end

  def horizontal_border_segment(
        %{
          row_number: row_number,
          column: column,
          puzzle: %{size: board_size, borders: borders, published_at: published_at} = _puzzle
        } = assigns
      )
      when row_number < board_size do
    border_id = Enum.join([row_number, column, "-", row_number + 1, column])
    maybe_editable = (published_at && %{}) || %{"phx-click" => "toggle_border"}
    maybe_clickable = (published_at && "") || "clickable"

    ~H"""
    <div class={"h-border #{maybe_clickable} #{borders[border_id]}"}
      {maybe_editable} phx-value-border={border_id}
    >
    </div>
    """
  end

  def horizontal_border_segment(assigns) do
    ~H"""
    <div class="h-border" ></div>
    """
  end

  def intersection(assigns) do
    ~H"""
    <div class="intersection" {assigns}></div>
    """
  end

  def vertical_border_segment(
        %{
          row_number: row_number,
          column: column,
          puzzle: %{size: board_size, borders: borders, published_at: published_at}
        } = assigns
      )
      when column < board_size do
    border_id = Enum.join([row_number, column, "-", row_number, column + 1])
    maybe_editable = (published_at && %{}) || %{"phx-click" => "toggle_border"}
    maybe_clickable = (published_at && "") || "clickable"

    ~H"""
    <div class={"v-border #{maybe_clickable} #{borders[border_id]}"}
      {maybe_editable} phx-value-border={border_id}
    >
    </div>
    """
  end

  def vertical_border_segment(assigns) do
    ~H"""
    <div class="v-border" ></div>
    """
  end
end
