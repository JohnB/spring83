defmodule Venue do
  @cal_venue_id "keywords=berkeley+greek+theater"
  @la_venue_id "keywords=Los+Angeles+greek+theater"
  @cornerstone_id "keywords=berkeley+cornerstone"

  @month_to_number %{
    "Jan" => "01",
    "Feb" => "02",
    "Mar" => "03",
    "Apr" => "04",
    "May" => "05",
    "Jun" => "06",
    "Jul" => "07",
    "Aug" => "08",
    "Sep" => "09",
    "Oct" => "10",
    "Nov" => "11",
    "Dec" => "12"
  }

  defstruct venue_id: @cal_venue_id, events: nil, fetched_at: nil

  def fetch_events(%__MODULE__{venue_id: venue_id} = venue) do
    html = HTTPoison.get!("https://tickets-center.com/search?#{venue_id}").body
    {:ok, document} = Floki.parse_document(html)

    events =
      Floki.find(document, "[data-testid=event-table]")
      |> Floki.find("section")

    {year, _} = Date.utc_today() |> Date.year_of_era()

    event_summaries =
      events
      |> Enum.reduce(%{}, fn event, acc ->
        performer = Floki.find(event, "[data-testid=eventName]") |> Floki.text()
        time = Floki.find(event, "[data-testid=time]") |> Floki.text()
        dow = Floki.find(event, "[data-testid=dayOfWeekSm]") |> Floki.text()
        [mon, day] = Floki.find(event, "[data-testid=month]") |> Floki.text() |> String.split(" ")
        month_num = @month_to_number[mon]

        yyyymmdd = Enum.join([year, month_num, String.pad_leading(day, 2, "0")])

        Map.put(acc, yyyymmdd, %{
          "dow" => dow,
          "month" => mon,
          "day" => day,
          "time" => time,
          "performer" => performer
        })
      end)

    %__MODULE__{venue | events: event_summaries, fetched_at: today_yyyymmdd()}
    |> IO.inspect()
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
  def cornerstone, do: %__MODULE__{venue_id: @cornerstone_id}
end
