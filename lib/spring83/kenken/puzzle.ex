defmodule Spring83.Kenken.Puzzle do
  use Ecto.Schema
  import Ecto.Changeset

  schema "kenken_puzzle" do
    field :borders, {:map, :string}
    field :cell_values, {:map, :string}
    field :name, :string
    field :published_at, :naive_datetime
    field :size, :integer

    timestamps()
  end

  @doc false
  def changeset(puzzle, attrs) do
    puzzle
    |> cast(attrs, [:name, :size, :borders, :cell_values, :published_at])
    |> validate_required([:name, :size, :borders, :cell_values, :published_at])
  end
end
