defmodule KuraWeb.Schema.ChartTypes do
  use Absinthe.Schema.Notation

  alias KuraWeb.Resolvers
  alias KuraWeb.Schema.Middleware

  object :data do
    field :label, :string
    field :values, list_of(:decimal)
  end

  object :pnl_data do
    field :categories, list_of(:string)
    field :series, :data
  end

  object :pnl_comp_data do
    field :exit_date, :date
    field :period, :string
    field :cumulated_pnl, :decimal
  end

  object :chart_queries do
    field :pnl_chart, :pnl_data do
      middleware(Middleware.Authorize)
      resolve(&Resolvers.Charts.pnl_chart/3)
    end

    field :pnl_comp_chart, list_of(:pnl_comp_data) do
      middleware(Middleware.Authorize)
      resolve(&Resolvers.Charts.pnl_comp_chart/3)
    end
  end
end
