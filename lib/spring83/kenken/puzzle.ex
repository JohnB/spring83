defmodule Spring83.Kenken.Puzzle do
  use Ecto.Schema
  alias Ecto.Query
  import Ecto.Changeset
  alias Spring83.Repo

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
    |> validate_required([:name, :size, :borders, :cell_values])
  end

  def get_puzzle(id), do: Repo.get!(__MODULE__, id)
  #  def recent_puzzles(), do: Repo.get!(__MODULE__, id)

  def create_puzzle(attrs \\ %{}) do
    defaults = %{
      size: 7,
      borders: %{},
      cell_values: %{},
      published_at: nil,
      name: NaiveDateTime.utc_now() |> NaiveDateTime.to_string() |> String.slice(0, 19)
    }

    {:ok, puzzle} =
      %__MODULE__{}
      |> changeset(Map.merge(defaults, attrs))
      |> Repo.insert(returning: true)

    puzzle
  end

  def update_puzzle(%__MODULE__{} = puzzle, attrs) do
    {:ok, puzzle} =
      puzzle
      |> changeset(attrs)
      |> Repo.update(returning: true)

    puzzle
  end
end
