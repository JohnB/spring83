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
    query = from c in __MODULE__, order_by: [desc: c.inserted_at], limit: 1

    case Repo.one(query) do
      nil -> nil
      canvas -> Enum.with_index(canvas.canvas, fn element, index -> {index, element} end)
    end
  end

  def save(canvas_with_indexes) do
    just_canvas = Enum.map(canvas_with_indexes, fn {_idx, color} -> color end)
    Repo.insert(%__MODULE__{canvas: just_canvas})
  end
end
