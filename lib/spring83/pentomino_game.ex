defmodule Spring83.PentominoGame do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pentomino_games" do
    field :name, :string
    field :height, :integer
    field :width, :integer
    field :start_x, :integer
    field :start_y, :integer
    field :player_0_id, :string
    field :player_1_id, :string
    field :player_2_id, :string
    field :player_3_id, :string
    field :game_title, :string

    timestamps()
  end

  @doc false
  def changeset(pentomino_game, attrs) do
    pentomino_game
    |> cast(attrs, [
      :name,
      :height,
      :width,
      :start_x,
      :start_y,
      :player_0_id,
      :player_1_id,
      :player_2_id,
      :player_3_id,
      :game_title
    ])
    |> validate_required([
      :name,
      :height,
      :width,
      :start_x,
      :start_y,
      :player_0_id,
      :player_1_id,
      :player_2_id,
      :player_3_id,
      :game_title
    ])
  end
end
