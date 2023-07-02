# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :spring83,
  ecto_repos: [Spring83.Repo]

# Configures the endpoint
config :spring83, Spring83Web.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: Spring83Web.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Spring83.PubSub,
  live_view: [signing_salt: "3ERewZ/C"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :spring83, Spring83.Mailer, adapter: Swoosh.Adapters.Local
# See https://us-west-2.console.aws.amazon.com/ses/home?region=us-west-2#smtp-settings:
# For what Amazon Simple Email Service allows.
# See also: https://www.google.com/search?q=standard+SMTP+ports&oq=standard+SMTP+ports&aqs=chrome..69i57j0.6194j0j7&sourceid=chrome&ie=UTF-8
config :spring83, Spring83.Mailer,
       adapter: Bamboo.SMTPAdapter,
       server: "email-smtp.us-west-2.amazonaws.com",
       port: 587, # or 25, or 587,
       username: System.get_env("SMTP_USERNAME"),
       password: System.get_env("SMTP_PASSWORD"),
       tls: :always, # can be `:always`, ':if_available' or `:never`
       ssl: false, # can be `true`
       retries: 1


# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
