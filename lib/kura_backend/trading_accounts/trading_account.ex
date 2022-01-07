defmodule KuraBackend.TradingAccounts.TradingAccount do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "trading_accounts" do
    field :currency, :string
    field :name, :string
    field :user_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(trading_account, attrs) do
    trading_account
    |> cast(attrs, [:currency, :name])
    |> validate_required([:currency, :name])
  end
end
