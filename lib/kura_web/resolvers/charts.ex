defmodule KuraWeb.Resolvers.Charts do
  alias Kura.Charts.{PnlChart, PnlCompChart}

  def pnl_chart(_parent, _args, %{context: %{current_user: current_user}}) do
    {:ok, PnlChart.generate(current_user.id)}
  end

  def pnl_comp_chart(_parent, _args, %{context: %{current_user: current_user}}) do
    {:ok, PnlCompChart.generate(current_user.id)}
  end
end
