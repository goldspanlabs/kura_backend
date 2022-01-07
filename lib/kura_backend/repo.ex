defmodule KuraBackend.Repo do
  use Ecto.Repo,
    otp_app: :kura_backend,
    adapter: Ecto.Adapters.Postgres
end
