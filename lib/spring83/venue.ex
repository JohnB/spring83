defmodule Venue do
  @cal_venue_id 1928
  @la_venue_id 672

  @month_to_number %{
    "January" => "01",
    "February" => "02",
    "March" => "03",
    "April" => "04",
    "May" => "05",
    "June" => "06",
    "July" => "07",
    "August" => "08",
    "September" => "09",
    "October" => "10",
    "November" => "11",
    "December" => "12"
  }

  defstruct venue_id: @cal_venue_id, events: nil, fetched_at: nil

  def fetch_events(%__MODULE__{venue_id: venue_id} = venue) do
    regex =
      ~r/^(?<dow>.+), (?<month>.+) (?<day>.+), (?<year>\d{4}) at (?<time>.+?), (?<performer>.+) at.*/

    html = HTTPoison.get!("https://tickets-center.com/search?venueId=#{venue_id}").body
    {:ok, document} = Floki.parse_document(html)

    events =
      Floki.find(document, "#event-list")
      |> Floki.find("[aria-label]")
      |> Floki.attribute("aria-label")
      |> Enum.reject(fn x -> x == "Click to View Tickets" end)

    event_summaries =
      events
      |> Enum.reduce(%{}, fn event_string, acc ->
        event_captures = Regex.named_captures(regex, event_string)

        case event_captures do
          nil ->
            acc

          event_map ->
            yyyymmdd =
              Enum.join([
                event_map["year"],
                @month_to_number[event_map["month"]],
                String.pad_leading(event_map["day"], 2, "0")
              ])

            Map.put(acc, yyyymmdd, event_map)
        end
      end)

    %__MODULE__{venue | events: event_summaries, fetched_at: today_yyyymmdd()}
  end

  def today_yyyymmdd do
    {:ok, now} = DateTime.now("America/Los_Angeles")

    Enum.join([
      now.year,
      String.pad_leading(Integer.to_string(now.month), 2, "0"),
      String.pad_leading(Integer.to_string(now.day), 2, "0")
    ])
  end

  def cal_default, do: %__MODULE__{venue_id: @cal_venue_id}
  def la_default, do: %__MODULE__{venue_id: @la_venue_id}
end
