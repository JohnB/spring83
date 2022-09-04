defmodule Spring83.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Spring83.Repo,
      # Start the Telemetry supervisor
      Spring83Web.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Spring83.PubSub},
      # Start the Endpoint (http/https)
      Spring83Web.Endpoint,
      # Start a worker by calling: Spring83.Worker.start_link(arg)
      # {Spring83.Worker, arg}

      Spring83Web.CanvasSharedState
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Spring83.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    Spring83Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
