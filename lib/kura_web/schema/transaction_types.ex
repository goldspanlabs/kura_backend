defmodule KuraWeb.Schema.TransactionTypes do
  use Absinthe.Schema.Notation

  alias KuraWeb.Resolvers
  alias KuraWeb.Schema.Middleware

  object :transaction do
    field :id, :string
    field :symbol, :string
    field :strategy, :string
    field :strategy_id, :string
    field :trade_date, :string
    field :price, :decimal
    field :fee, :decimal
    field :quantity, :integer
    field :total_cost, :decimal
    field :asset_type, :string
    field :option_type, :string
    field :expiration, :string
    field :strike, :decimal
    field :action, :string
    field :trading_account_id, :string
    field :trading_account_name, :string
  end

  input_object :transactions_input do
    field :trading_account_id, :string
    field :action, :string
    field :asset_type, :string
    field :fee, :decimal
    field :price, :decimal
    field :quantity, :integer
    field :strategy_id, :string
    field :symbol, :string
    field :trade_date, :date
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

    field :strategy_details, list_of(:transaction) do
      arg(:root, non_null(:string))
      arg(:strategy_id, non_null(:string))
      middleware(Middleware.Authorize)
      resolve(&Resolvers.Transactions.strategy_details/3)
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

    field :upload_file, :string do
      arg(:file, non_null(:upload))
      arg(:account_id, non_null(:id))

      resolve(&Resolvers.Transactions.file_upload/3)
    end
  end
end
