defmodule KuraBackend.Repo.Migrations.AddOptionFieldsToTransactions do
  use Ecto.Migration

  def change do
    alter table("transactions") do
      add :expiration, :date
      add :strike, :decimal
      add :option_type, :string
    end
  end
end
