defmodule Kura.Transactions.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "transactions" do
    field :action, :string
    field :asset_type, :string
    field :fee, :decimal
    field :price, :decimal
    field :quantity, :integer
    field :symbol, :string
    field :trade_date, :date
    field :expiration, :date
    field :strike, :decimal
    field :option_type, :string
    field :strategy_id, :string
    field :trading_account_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [
      :symbol,
      :trade_date,
      :price,
      :fee,
      :quantity,
      :asset_type,
      :action,
      :expiration,
      :strike,
      :option_type,
      :strategy_id,
      :trading_account_id
    ])
    |> validate_required([
      :symbol,
      :trade_date,
      :price,
      :fee,
      :quantity,
      :asset_type,
      :action,
      :strategy_id,
      :trading_account_id
    ])
  end

  def update_changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [
      :symbol,
      :trade_date,
      :price,
      :fee,
      :quantity,
      :asset_type,
      :action,
      :expiration,
      :strike,
      :option_type,
      :strategy_id,
      :trading_account_id
    ])
  end
end
