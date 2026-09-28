defmodule Spring83.Repo.Migrations.CreatePentominoGames do
  use Ecto.Migration

  def change do
    create table(:pentomino_games) do
      add :name, :string
      add :height, :integer
      add :width, :integer
      add :start_x, :integer
      add :start_y, :integer
      add :player_0_id, :string
      add :player_1_id, :string
      add :player_2_id, :string
      add :player_3_id, :string
      add :game_title, :string

      timestamps()
    end
  end
end
