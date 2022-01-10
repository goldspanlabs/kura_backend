defmodule KuraBackendWeb.Schema.TransactionTypes do
  use Absinthe.Schema.Notation

  alias KuraBackendWeb.Resolvers
  alias KuraBackendWeb.Schema.Middleware

  object :transaction do
    field :id, :string
    field :symbol, :string
    field :strategy, :string
    field :trade_date, :string
    field :price, :decimal
    field :fee, :decimal
    field :quantity, :integer
    field :total_cost, :decimal
    field :asset_type, :string
    field :action, :string
    field :trading_account_id, :string
    field :trading_account_name, :string
  end

  object :transaction_queries do
    field :transactions, list_of(:transaction) do
      middleware(Middleware.Authorize)
      resolve(&Resolvers.Transactions.list_transactions/3)
    end
  end
end
