defmodule KuraBackendWeb.Resolvers.Charts do
  def pnl_chart(_parent, _args, %{context: %{current_user: current_user}}) do
    {:ok, KuraBackend.Charts.pnl_chart(current_user.id)}
  end

  def pnl_comp_chart(_parent, _args, %{context: %{current_user: current_user}}) do
    {:ok, KuraBackend.Charts.pnl_comp_chart(current_user.id)}
  end
end
