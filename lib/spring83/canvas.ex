defmodule Spring83.Canvas do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Spring83.Repo

  schema "canvases" do
    field :canvas, {:array, :string}

    timestamps()
  end

  @doc false
  def changeset(canvas, attrs) do
    canvas
    |> cast(attrs, [:canvas])
    |> validate_required([:canvas])
  end

  # Should this be somewhere else?

  # NOTE: The DB just stores the class names, not the indexes, so we recreate
  # the indexes after fetching from the DB.
  def latest do
    query = from c in __MODULE__, order_by: [desc: c.id], limit: 1, select: [:canvas]

    case Repo.one(query) do
      nil -> nil
      canvas -> Enum.with_index(canvas.canvas, fn element, index -> {index, element} end)
    end
  end

  def save(canvas_with_indexes) do
    just_canvas = Enum.map(canvas_with_indexes, fn {_idx, color} -> color end)
    Repo.insert(%__MODULE__{canvas: just_canvas})
  end

  def historical_css do
    raw_historical_canvases()
    # Transpose to get colors for each historical cell
    |> Enum.zip_with(& &1)
    |> Enum.with_index(fn cell_colors, keyframe_id ->
      [
        "@keyframes history-frame-#{keyframe_id} {",
        cell_colors
        # Only write a keyframe when it changes (rarely) by
        # structuring the data as follows:
        #   [{color, progress_percent}, {previous_color, _previous_progress_percent}]
        # to compare color to previous_color and only keep the changes.
        |> Enum.with_index()
        |> Enum.reverse()
        |> Enum.chunk_every(2, 1, [{"", 0}])
        |> Enum.reverse()
        |> Enum.map(fn [{color, progress_percent}, {previous_color, _previous_progress_percent}] ->
          (color != previous_color && "#{progress_percent}% { background: #{cell_color(color)}; }") ||
            nil
        end),
        "100% { background: #{cell_color(List.first(cell_colors))}; }",
        "}"
      ]
    end)
    |> List.flatten()
    # drop out nils
    |> Enum.filter(fn x -> x end)
    |> Enum.join("\n")
  end

  def raw_historical_canvases do
    # max of 99 rows is important since we'll step from 0% to 100% thru the animation
    # without short-changing the *current* image.
    query = from c in __MODULE__, order_by: [desc: c.id], limit: 99, select: [:canvas]

    rows = Repo.all(query)

    case rows do
      nil -> nil
      rows -> Enum.map(rows, fn row -> row.canvas end) |> Enum.reverse()
    end
  end

  # convert my color-named CSS classes to what the CSS would give
  # TODO: fix this somehow
  def cell_color(""), do: "white"
  def cell_color("blue"), do: "aqua"
  def cell_color("green"), do: "lightgreen"
  def cell_color("purple"), do: "mediumpurple"
  def cell_color(color), do: color
end
