defmodule Spring83.Repo do
  use Ecto.Repo,
    otp_app: :spring83,
    adapter: Ecto.Adapters.Postgres
end
