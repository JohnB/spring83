defmodule Spring83Web.PageView do
  use Spring83Web, :view
  use Phoenix.Component

  def color_picker_class(color, selected_color) do
    case color == selected_color do
      true -> "color-picker #{color} selected"
      _ -> "color-picker #{color}"
    end
  end

  def modal(assigns) do
    ~H"""
    <div class="modal">
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  #  attr :project, :string
#  attr :theme, :string
  def learning(assigns) do
    ~H"""
    <div class="learning">
      <span class="theme"><%= @theme %></span>
      <span class="project"><%= @project %></span>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
