defmodule Brave.Repo do
  use Ecto.Repo,
    otp_app: :brave,
    adapter: Ecto.Adapters.Postgres
end
