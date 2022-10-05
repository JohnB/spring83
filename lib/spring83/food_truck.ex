defmodule Spring83.FoodTruck do
  use Ecto.Schema
  import Ecto.Changeset

  schema "food_trucks" do
    field :applicant, :string
    field :fooditems, :string
    field :locationdescription, :string
    field :latitude, :float
    field :longitude, :float
    field :status, :string

    timestamps()
  end

  @doc false
  def changeset(food_truck, attrs \\ %{}) do
    food_truck
    |> cast(attrs, [:applicant, :locationdescription, :latitude, :longitude, :status])
    |> validate_required([:latitude, :longitude, :status])
  end

  def from_json(%{} = parsed_json) do
    %__MODULE__{
      applicant: Map.get(parsed_json, "applicant"),
      fooditems: Map.get(parsed_json, "fooditems"),
      locationdescription: Map.get(parsed_json, "locationdescription"),
      latitude: Map.get(parsed_json, "latitude", "0.0") |> Float.parse() |> elem(0),
      longitude: Map.get(parsed_json, "longitude", "0.0") |> Float.parse() |> elem(0),
      status: Map.get(parsed_json, "status", "")
    }
  end

  def plausible_location?(%__MODULE__{latitude: 0.0}), do: false
  def plausible_location?(%__MODULE__{longitude: 0.0}), do: false
  def plausible_location?(_), do: true

  def approved?(%__MODULE__{status: "APPROVED"}), do: true
  def approved?(_), do: false
end
