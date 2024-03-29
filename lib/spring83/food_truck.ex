defmodule Spring83.FoodTruck do
  use Ecto.Schema

  schema "food_trucks" do
    field :applicant, :string
    field :fooditems, :string
    field :locationdescription, :string
    field :latitude, :float
    field :longitude, :float
    field :objectid, :string
    field :status, :string

    timestamps()
  end

  # In a globally-connected world, what is "japanese"?
  @seems_japanese ~r/japan|tako|poke bowl|donburi/i

  def from_json(%{} = parsed_json) do
    %__MODULE__{
      applicant: Map.get(parsed_json, "applicant"),
      fooditems: Map.get(parsed_json, "fooditems"),
      locationdescription: Map.get(parsed_json, "locationdescription"),
      latitude: Map.get(parsed_json, "latitude", "0.0") |> Float.parse() |> elem(0),
      longitude: Map.get(parsed_json, "longitude", "0.0") |> Float.parse() |> elem(0),
      objectid: Map.get(parsed_json, "objectid", ""),
      status: Map.get(parsed_json, "status", "")
    }
  end

  def vendor_name(%__MODULE__{applicant: applicant}) do
    applicant
    |> String.split("DBA")
    |> List.last()
    |> String.split("dba")
    |> List.last()
    |> String.split("/")
    |> List.last()
    |> String.replace(", LLC", "")
    |> String.replace("LLC", "")
    |> String.replace("Inc.", "")
    |> String.trim()
    |> String.replace_trailing(".", "")
    |> String.replace_trailing(",", "")
    |> String.replace_leading(":", "")
    |> String.replace_leading(".", "")
  end

  # The Maps API expects a `content` option field to include HTML
  # to display in the InfoWindow - and I don't see a way to use
  # a ~H element to build the HTML so we're just generating it.
  def offerings(%__MODULE__{} = food_truck) do
    "<h3>#{vendor_name(food_truck)}</h3>" <> food_list(food_truck)
  end

  defp food_list(%__MODULE__{fooditems: fooditems}) do
    fooditems
    |> String.replace(~r/;|:/, "<br />")
  end

  def maybe_japanese?(%__MODULE__{fooditems: fooditems}) do
    fooditems =~ @seems_japanese
  end

  def plausible_location?(%__MODULE__{latitude: 0.0}), do: false
  def plausible_location?(%__MODULE__{longitude: 0.0}), do: false
  def plausible_location?(_), do: true

  def approved?(%__MODULE__{status: "APPROVED"}), do: true
  def approved?(_), do: false

  def google_maps_api_key do
    System.get_env("GOOGLE_MAPS_API_KEY")
  end
end
