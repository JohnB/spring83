defmodule Spring83.PentominoMove do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pentomino_moves" do
    field :pentomino_game_id, :string
    field :move_number, :integer
    field :move, :string
    field :comment, :string

    timestamps()
  end

  @doc false
  def changeset(pentomino_move, attrs) do
    pentomino_move
    |> cast(attrs, [:pentomino_game_id, :move_number, :move, :comment])
    |> validate_required([:pentomino_game_id, :move_number, :move, :comment])
  end
end
