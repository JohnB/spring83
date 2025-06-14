defmodule Spring83.MixProject do
  use Mix.Project

  def project do
    [
      app: :spring83,
      version: "0.1.0",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Spring83.Application, []},
      extra_applications: [
        :logger,
        :runtime_tools
        # :bamboo,
        # :bamboo_smtp
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.7.21"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.6"},
      {:postgrex, ">= 0.16.5"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_dashboard, "~> 0.8"},
      {:phoenix_live_view, "~> 0.20"},
      {:phoenix_view, "~> 2.0"},
      {:floki, ">= 0.30.0"},
      {:esbuild, "~> 0.4", runtime: Mix.env() == :dev},
      {:swoosh, "~> 1.8"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.18"},
      # Needed for spring83
      {:jason, "~> 1.4"},
      {:plug_cowboy, "~> 2.5"},
      {:httpoison, "~> 1.8"},
      {:ed25519, "~> 1.4.1"},
      # Needed for Collaborative canvas
      {:ets, "~> 0.9"},
      # Needed for todays_pizza
      {:oauther, "~> 1.1"},
      # {:extwitter, "~> 0.13"},
      {:timex, "~> 3.7"},
      {:hunter, "~> 0.5.1"},
      # {:bamboo_smtp, "~> 4.2"},
      # {:bamboo_phoenix, "~> 1.0"}
      {:req, "~> 0.5.8"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.deploy": ["esbuild default --minify", "phx.digest"]
    ]
  end
end
