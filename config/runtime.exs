import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/spring83 start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :spring83, Spring83Web.Endpoint, server: true
end

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 = if System.get_env("ECTO_IPV6"), do: [:inet6], else: []

  config :spring83, Spring83.Repo,
    # ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :spring83, Spring83Web.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base

  # Configures the mailer
  #
  # By default it uses the "Local" adapter which stores the emails
  # locally. You can see the emails in your browser, at "/dev/mailbox".
  #
  # For production it's recommended to configure a different adapter
  # at the `config/runtime.exs`.
  #config :spring83, Spring83.Mailer, adapter: Swoosh.Adapters.Local
  # See https://us-west-2.console.aws.amazon.com/ses/home?region=us-west-2#smtp-settings:
  # For what Amazon Simple Email Service allows.
  # See also: https://www.google.com/search?q=standard+SMTP+ports&oq=standard+SMTP+ports&aqs=chrome..69i57j0.6194j0j7&sourceid=chrome&ie=UTF-8
  config :spring83, Spring83.Mailer,
         adapter: Bamboo.SMTPAdapter,
         server: "email-smtp.us-west-2.amazonaws.com",
         port: 587, # or 25, or 587,
         username: System.get_env("SMTP_USERNAME"),
         password: System.get_env("SMTP_PASSWORD"),
         tls: :if_available, # can be `:always`, ':if_available' or `:never`
         tls_verify: :verify_peer,
         auth: :always,
         ssl: false, # can be `true`
         retries: 1

  # ## Configuring the mailer
  #
  # In production you need to configure the mailer to use a different adapter.
  # Also, you may need to configure the Swoosh API client of your choice if you
  # are not using SMTP. Here is an example of the configuration:
  #
  # consider https://hexdocs.pm/swoosh/Swoosh.Adapters.AmazonSES.html
  #  config :spring83, Spring83.Mailer,
  #   adapter: Swoosh.Adapters.Mailgun,
  #   api_key: System.get_env("MAILGUN_API_KEY"),
  #   domain: System.get_env("MAILGUN_DOMAIN")
  #
  # For this example you need include a HTTP client required by Swoosh API client.
  # Swoosh supports Hackney and Finch out of the box:
  #
  #     config :swoosh, :api_client, Swoosh.ApiClient.Hackney
  #
  # See https://hexdocs.pm/swoosh/Swoosh.html#module-installation for details.
end
