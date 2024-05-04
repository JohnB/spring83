defmodule Spring83.PizzaCache do
  use Agent
  require Logger

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
  @extract_month_and_day ~r/\w+ (?<month>.+) (?<day>.+)/

  def start_link(_) do
    Logger.info("Starting PizzaCache")
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def pizza_for(yyyymmdd) do
    map = get()

    if map[yyyymmdd] do
      map[yyyymmdd]
    else
      latest = TodaysPizza.fetch_dates_and_topping() |> normalize_dates(map)
      Agent.update(__MODULE__, fn x -> Map.merge(x, latest) end)
      latest[yyyymmdd]
    end
  end

  def get do
    Agent.get(__MODULE__, & &1)
  end

  def normalize_dates(dates_and_pizzas, existing \\ %{}) do
    year = DateTime.utc_now().year

    Enum.reduce(dates_and_pizzas, existing, fn [date, pizza], acc ->
      %{"day" => day, "month" => month} = Regex.named_captures(@extract_month_and_day, date)
      Map.put(acc, "#{year}#{@month_to_number[month]}#{String.pad_leading(day, 2, "0")}", pizza)
    end)
  end
end
