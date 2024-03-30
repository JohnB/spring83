defmodule Spring83Web.Router do
  use Spring83Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {Spring83Web.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Spring83Web do
    pipe_through :browser

    get "/", PageController, :index

    # Spring83 routes
    get "/boards", BoardController, :index

    # Collaborative Canvas routes
    live "/collaborative_canvas", CollaborativeCanvasLive

    # Cheese board routes (twitter: @Todays_pizza)
    get "/pizza", PizzaController, :index

    # Kenken routes
    live "/kenken/*puzzle_id", KenkenLive

    # Street Food routes (for a job interview)
    live "/street_food", StreetFoodLive

    # VDiff - visual diff (POC for a friend)
    live "/vdiff", VDiffLive

    # whoisatthegreek.com and whoisatthelagreek.com
    #    live "/whoisatthegreek.com", WhoIsAtTheLive, :cal_greek
    #    live "/whoisatthelagreek.com", WhoIsAtTheLive, :la_greek
    # link to buy tix
    # https://tickets-center.com/tickets/?eventId=4344297&venueId=1928&performerId=1716
    #
    #regex = ~r/^(?<dow>.+), (?<month>.+) (?<day>.+), (?<year>\d{4}) at (?<time>.+?), (?<performer>.+) at.*/
    # html = HTTPoison.get!("https://tickets-center.com/search?venueId=1928").body
    # {:ok, document} = Floki.parse_document(html)
    #events = Floki.find(document, "#event-list") |> Floki.find("[aria-label]") |> Floki.attribute("aria-label") |> Enum.reject(fn x -> x == "Click to View Tickets" end)
    #Enum.map(events, fn x -> Regex.named_captures(regex, x) end)

  end

  # Other scopes may use custom stacks.
  # scope "/api", Spring83Web do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: Spring83Web.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
