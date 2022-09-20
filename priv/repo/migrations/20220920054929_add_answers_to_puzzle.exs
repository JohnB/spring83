defmodule Spring83.Repo.Migrations.AddAnswersToPuzzle do
  use Ecto.Migration

  def change do
    alter table(:kenken_puzzle) do
      add :answers, {:map, :string}
    end
  end
end
