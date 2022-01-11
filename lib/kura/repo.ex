defmodule Kura.Repo do
  use Ecto.Repo,
    otp_app: :kura,
    adapter: Ecto.Adapters.Postgres

  def truncate(schema) do
    table_name = schema.__schema__(:source)
    query("TRUNCATE #{table_name};", [])
    :ok
  end

  def truncate(schema, :cascade) do
    table_name = schema.__schema__(:source)
    query("TRUNCATE #{table_name} CASCADE;", [])
    :ok
  end
end
