defmodule Kura.Repo.Migrations.AlterTransactionTimestamps do
  use Ecto.Migration

  def change do
    alter table(:transactions) do
      modify :inserted_at, :utc_datetime, default: fragment("NOW()")
      modify :updated_at, :utc_datetime, default: fragment("NOW()")
    end
  end
end
