defmodule Spring83Web.PentominoView do
  use Spring83Web, :view

  @width 20
  #  @height 20
  @internal_width 2 + @width
  #  @internal_height 2 + @height

  @top_left_offset 1 + @internal_width

  def board_position_to_internal_poard_index(x, y) do
    @top_left_offset + x + @internal_width * y
  end
end
