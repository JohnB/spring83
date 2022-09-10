defmodule Spring83.Canvas do
  use Ecto.Schema
  import Ecto.Changeset

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
end
