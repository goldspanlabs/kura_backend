defmodule KuraBackendWeb.Schema.PositionTypes do
  use Absinthe.Schema.Notation

  alias KuraBackendWeb.Resolvers
  alias KuraBackendWeb.Schema.Middleware

  import_types(Absinthe.Type.Custom)

  object :open_position do
    field :symbol, :string
    field :symbol_label, :string
    field :root, :string
    field :strategy, :string
    field :strategy_label, :string
    field :trade_date, :date
    field :expiration, :date
    field :option_type, :string
    field :avg_price, :decimal
    field :book_cost, :decimal
    field :quantity, :integer
    field :days_from_expiration, :integer
    field :days_to_expiration, :integer
    field :strike, :decimal
    field :account_id, :string
    field :account_name, :string
    field :user_id, :string
  end

  object :closed_position do
    field :symbol, :string
    field :symbol_label, :string
    field :root, :string
    field :strategy, :string
    field :strategy_label, :string
    field :expiration, :date
    field :entry_date, :date
    field :exit_date, :date
    field :days_in_trade, :integer
    field :entry_cost, :decimal
    field :exit_cost, :decimal
    field :total_fees, :decimal
    field :realized_pnl, :decimal
    field :account_id, :string
    field :account_name, :string
    field :user_id, :string
  end

  @desc "List user positions"
  object :position_queries do
    field :open_positions, list_of(:open_position) do
      middleware(Middleware.Authorize)
      resolve(&Resolvers.Positions.open_positions/3)
    end

    field :closed_positions, list_of(:closed_position) do
      middleware(Middleware.Authorize)
      resolve(&Resolvers.Positions.closed_positions/3)
    end
  end
end
