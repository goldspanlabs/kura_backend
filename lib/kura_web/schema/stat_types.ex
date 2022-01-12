defmodule KuraWeb.Schema.StatTypes do
  use Absinthe.Schema.Notation

  alias KuraWeb.Resolvers
  alias KuraWeb.Schema.Middleware

  object :dashboard_stats do
    field :avg_pnl, :decimal
    field :total_pnl, :decimal
    field :total_fees, :decimal
    field :win_rate, :decimal
  end

  object :stat_queries do
    field :dashboard_stats, :dashboard_stats do
      middleware(Middleware.Authorize)
      resolve(&Resolvers.Statistics.dashboard_stats/3)
    end
  end
end
