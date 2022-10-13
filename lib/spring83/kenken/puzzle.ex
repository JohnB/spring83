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
    field :answers, {:map, :string}

    # Per-user data that is not persisted but handy to work with.
    field :selected, :string, virtual: true
    field :guesses, {:map, {:array, :string}}, virtual: true

    timestamps()
  end

  @doc false
  def changeset(puzzle, attrs) do
    puzzle
    |> cast(attrs, [
      :name,
      :size,
      :borders,
      :cell_values,
      :published_at,
      :selected,
      :guesses,
      :answers
    ])
    |> validate_required([:name, :size, :borders, :cell_values])
  end

  def get_puzzle(id), do: Repo.get!(__MODULE__, id)

  def recent_puzzles() do
    Repo.all(
      from p in __MODULE__,
        where: not is_nil(p.published_at),
        order_by: [desc: :published_at],
        select: [:id, :name, :size]
    )
  end

  def unpublished_puzzles() do
    Repo.all(
      from p in __MODULE__,
        where: is_nil(p.published_at),
        order_by: [desc: :id],
        select: [:id, :name, :size]
    )
  end

  def create_puzzle(attrs \\ %{}) do
    defaults = %{
      size: 7,
      borders: %{},
      cell_values: %{},
      answers: %{},
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

  def selected_guess?(%__MODULE__{guesses: guesses} = _puzzle, cell_id, guess) do
    guess_list = guesses[cell_id] || []
    Enum.member?(guess_list, "#{guess}")
  end

  def neighbor_selected?(%__MODULE__{guesses: guesses} = puzzle, cell_id, guess) do
    cond do
      # This assumes we know we're not the selected_guess - but a peer is selected
      Enum.count(guesses[cell_id] || []) > 0 ->
        true

      # Did a row or column neighbor select this guess?
      Enum.any?(neighboring_cell_ids(puzzle, cell_id), fn neighbor_id ->
        selected_guess?(puzzle, neighbor_id, guess)
      end) ->
        true

      true ->
        false
    end
  end

  # Return a list of all the neighbors in the same column and row,
  # excluding our own cell.
  defp neighboring_cell_ids(puzzle, cell_id) do
    [x, y] = String.split(cell_id, "", trim: true)

    for n <- 1..puzzle.size do
      [["#{x}#{n}"], ["#{n}#{y}"]]
    end
    |> List.flatten()
    |> Enum.reject(fn this_id -> this_id == cell_id end)
  end
end
