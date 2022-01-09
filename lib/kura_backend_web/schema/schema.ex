defmodule KuraBackendWeb.Schema do
  use Absinthe.Schema

  alias KuraBackendWeb.Schema

  import_types(Schema.UserTypes)
  import_types(Schema.TradingAccountTypes)
  import_types(Schema.PositionTypes)

  query do
    import_fields(:trading_accounts)
    import_fields(:position_queries)
  end

  mutation do
    import_fields(:session_mutation)
    import_fields(:create_user_mutation)
  end
end
