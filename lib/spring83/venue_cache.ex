defmodule Spring83.VenueCache do
  use Agent
  require Logger
  alias Venue

  def start_link(_) do
    Logger.info("Starting VenueCache")

    Agent.start_link(fn -> %{cal_greek: Venue.cal_default(), la_greek: Venue.la_default()} end,
      name: __MODULE__
    )
  end

  def venue_list(venue_atom) do
    map = get()[venue_atom]

    case map do
      nil ->
        raise("Venue #{venue_atom} not found.")

      %Venue{events: nil} = venue ->
        events = Venue.fetch_events(venue)
        Agent.update(__MODULE__, fn x -> Map.merge(x, %{venue_atom => events}) end)
        events

      %Venue{events: _} = venue ->
        venue
    end
  end

  def get do
    Agent.get(__MODULE__, & &1)
  end
end
