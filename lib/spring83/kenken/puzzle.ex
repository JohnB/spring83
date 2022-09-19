defmodule Spring83.Kenken.Puzzle do
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset
  alias Spring83.Repo

  schema "kenken_puzzle" do
    field :borders, {:map, :string}
    field :cell_values, {:map, :string}
    field :name, :string
    field :published_at, :naive_datetime
    field :size, :integer

    # Per-user data that is not persisted but handy to work with.
    field :selected, :string, virtual: true
    field :guesses, {:map, {:array, :string}}, virtual: true

    timestamps()
  end

  @doc false
  def changeset(puzzle, attrs) do
    puzzle
    |> cast(attrs, [:name, :size, :borders, :cell_values, :published_at, :selected, :guesses])
    |> validate_required([:name, :size, :borders, :cell_values])
  end

  def get_puzzle(id), do: Repo.get!(__MODULE__, id)
  def recent_puzzles() do
    Repo.all(from p in __MODULE__,
             where: is_nil(p.published_at),
             order_by: [desc: :published_at],
             select: [:id, :name]
    )
  end

  def create_puzzle(attrs \\ %{}) do
    defaults = %{
      size: 7,
      borders: %{},
      cell_values: %{},
      guesses: %{},
      selected: "",
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
