defmodule Spring83Web.PageView do

  use Gettext, backend: Spring83Web.Gettext
  use Spring83Web, :view

  def color_picker_class(color, selected_color) do
    case color == selected_color do
      true -> "color-picker #{color} selected"
      _ -> "color-picker #{color}"
    end
  end
end
