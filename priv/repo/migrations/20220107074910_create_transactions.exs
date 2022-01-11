defmodule Kura.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :symbol, :string
      add :trade_date, :date
      add :price, :decimal
      add :fee, :decimal
      add :quantity, :integer
      add :asset_type, :string
      add :action, :string
      add :strategy_id, references(:strategies, on_delete: :nothing, type: :binary_id)

      add :trading_account_id,
          references(:trading_accounts, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:transactions, [:strategy_id])
    create index(:transactions, [:trading_account_id])
  end
end
