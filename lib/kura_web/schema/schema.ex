defmodule KuraWeb.Schema do
  use Absinthe.Schema

  alias KuraWeb.Schema

  import_types(Absinthe.Type.Custom)
  import_types(Absinthe.Plug.Types)
  import_types(Schema.UserTypes)
  import_types(Schema.TradingAccountTypes)
  import_types(Schema.PositionTypes)
  import_types(Schema.TransactionTypes)
  import_types(Schema.ChartTypes)
  import_types(Schema.StatTypes)
  import_types(Schema.StrategyTypes)

  query do
    import_fields(:trading_account_queries)
    import_fields(:position_queries)
    import_fields(:transaction_queries)
    import_fields(:chart_queries)
    import_fields(:stat_queries)
    import_fields(:strategy_queries)
  end

  mutation do
    import_fields(:session_mutations)
    import_fields(:user_mutations)
    import_fields(:transaction_mutations)
  end
end
