defmodule Spring83Web.VDiffLive do
  @moduledoc """
    The plan: Build a live view with 6 distinct "pages"
    1) what this is, and ask for camera permission
    2) really ask for permission
    3) start showing video, with a _Take the "Before" Image_ button
    4) text reminding user that it is a POC and imagine that time goes by
       (turn around and ask someone to move a few things)
    5) Press "Start VDiff" and we get live video
      whose opacity slides back and forth with the "before" image
      and a _Take the "After" Image_ button.
    6) replace controls with an opacity slider and a "Retake" button

    Many thanks to this great article at https://web.dev/media-capturing-images/
    and to Josh Susser for articulating a need.
  """
  use Phoenix.LiveView
  require Logger

  def render(_assigns) do
    Spring83Web.VDiffView.render("vdiff.html", %{})
  end

  def mount(_params, _query_params, socket) do
    {:ok, assign(socket, %{page_title: "VDiff"})}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end
end
