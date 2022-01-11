defmodule KuraWeb.Schema.TransactionTypes do
  use Absinthe.Schema.Notation

  alias KuraWeb.Resolvers
  alias KuraWeb.Schema.Middleware

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

  input_object :transactions_input do
    field :trading_account_id, non_null(:string)
    field :action, non_null(:string)
    field :asset_type, non_null(:string)
    field :fee, non_null(:decimal)
    field :price, non_null(:decimal)
    field :quantity, non_null(:integer)
    field :strategy_id, non_null(:string)
    field :symbol, non_null(:string)
    field :trade_date, non_null(:date)
    field :expiration, :date
    field :strike, :decimal
    field :option_type, :string
  end

  object :transaction_queries do
    field :transactions, list_of(:transaction) do
      arg(:limit, :integer)
      middleware(Middleware.Authorize)
      resolve(&Resolvers.Transactions.list_transactions/3)
    end
  end

  object :transaction_mutations do
    field :insert_transactions_one, :transaction do
      arg(:object, non_null(:transactions_input))

      middleware(Middleware.Authorize)
      resolve(&Resolvers.Transactions.insert_transaction_one/3)
    end

    field :update_transaction_by_pk, :transaction do
      arg(:id, non_null(:id))
      arg(:object, non_null(:transactions_input))

      middleware(Middleware.Authorize)
      resolve(&Resolvers.Transactions.update_transaction_by_pk/3)
    end

    field :delete_transaction_by_pk, :transaction do
      arg(:id, non_null(:id))

      middleware(Middleware.Authorize)
      resolve(&Resolvers.Transactions.delete_transaction_by_pk/3)
    end
  end
end
