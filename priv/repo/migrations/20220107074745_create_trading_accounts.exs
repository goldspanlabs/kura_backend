defmodule KuraBackend.Repo.Migrations.CreateTradingAccounts do
  use Ecto.Migration

  def change do
    create table(:trading_accounts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :currency, :string
      add :name, :string
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:trading_accounts, [:user_id])
  end
end
