defmodule Spring83Web.KenkenView do
  use Spring83Web, :view

  def kenken_board(%{board_size: board_size} = assigns) do
    {board_size, _} = Integer.parse(board_size)

    ~H"""
    <div class={"kenken size#{board_size}"}>
      <.full_horizontal_border board_size={board_size} />
      <%= for row_number <- 1..board_size do %>
        <.row row_number={row_number} board_size={board_size} />
      <% end %>
    </div>
    """
  end

  def row(%{row_number: row_number, board_size: board_size} = assigns) do
    ~H"""
      <.vertical_border_segment />
      <%= for column <- 1..board_size do %>
        <.cell row_number={row_number}, column={column} />
        <.vertical_border_segment row_number={row_number} column={column} board_size={board_size} />
      <% end %>
      <.intersection />
      <%= for column <- 1..board_size do %>
        <.horizontal_border_segment row_number={row_number} column={column} board_size={board_size} />
        <.intersection />
    <% end %>
    """
  end

  def cell(%{row_number: row_number, column: column} = assigns) do
    cell_id = "#{row_number}#{column}"

    ~H"""
    <div class="cell" phx-click="edit_cell" phx-value-cell={cell_id}><%= cell_id %></div>
    """
  end

  def full_horizontal_border(%{board_size: board_size} = assigns) do
    ~H"""
    <.intersection />
    <%= for column  <- 1..board_size do %>
      <.horizontal_border_segment />
      <.intersection />
    <% end %>
    """
  end

  def horizontal_border_segment(
        %{row_number: row_number, column: column, board_size: board_size} = assigns
      )
      when row_number < board_size do
    border_id = Enum.join([row_number, column, "-", row_number + 1, column])

    ~H"""
    <div class="h-border clickable" phx-click="toggle_border" phx-value-border={border_id} ></div>
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
        %{row_number: row_number, column: column, board_size: board_size} = assigns
      )
      when column < board_size do
    border_id = Enum.join([row_number, column, "-", row_number, column + 1])

    ~H"""
    <div class="v-border clickable" phx-click="toggle_border" phx-value-border={border_id} ></div>
    """
  end

  def vertical_border_segment(assigns) do
    ~H"""
    <div class="v-border" ></div>
    """
  end
end
