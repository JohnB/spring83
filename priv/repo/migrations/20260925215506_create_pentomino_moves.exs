defmodule Spring83.Repo.Migrations.CreatePentominoMoves do
  use Ecto.Migration

  def change do
    create table(:pentomino_moves) do
      add :pentomino_game_id, :string
      add :move_number, :integer
      add :move, :string
      add :comment, :string

      timestamps()
    end
  end
end
