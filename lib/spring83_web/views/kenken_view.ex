defmodule Spring83Web.KenkenView do
  use Spring83Web, :view

  def kenken_board(%{size: board_size} = assigns) do
    ~H"""
    <p>KenkenView board_size: <%= board_size %></p>
    """
  end

end
