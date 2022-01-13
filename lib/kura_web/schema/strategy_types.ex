defmodule KuraWeb.Schema.StrategyTypes do
  use Absinthe.Schema.Notation

  alias KuraWeb.Resolvers
  alias KuraWeb.Schema.Middleware

  object :strategy do
    field :id, :string
    field :label, :string
    field :legs, :integer
  end

  object :strategy_queries do
    field :strategy, :strategy do
      arg(:strategy_id, non_null(:string))
      middleware(Middleware.Authorize)
      resolve(&Resolvers.Strategies.get_strategy/3)
    end
  end
end
