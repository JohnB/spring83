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
    # NOTE: "/*_" accepts anything, even the script kiddies "wp-includes/about.php", etc.
    get "/whoisatthegreek.com/*_", PageController, :cal_greek
    get "/whoisatthelagreek.com/*_", PageController, :la_greek
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
