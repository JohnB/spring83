defmodule Spring83.Repo.Migrations.CreateCanvases do
  use Ecto.Migration

  def change do
    create table(:canvases) do
      add :canvas, {:array, :string}

      timestamps()
    end
  end
end
