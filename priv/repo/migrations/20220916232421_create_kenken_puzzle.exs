defmodule Spring83.Repo.Migrations.CreateKenkenPuzzle do
  use Ecto.Migration

  def change do
    create table(:kenken_puzzle) do
      add :name, :string
      add :size, :integer
      add :borders, {:map, :string}
      add :cell_values, {:map, :string}
      add :published_at, :naive_datetime

      timestamps()
    end
  end
end
