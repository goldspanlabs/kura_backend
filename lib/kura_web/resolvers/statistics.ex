defmodule KuraWeb.Resolvers.Statistics do
  def dashboard_stats(_, _, %{context: %{current_user: current_user}}) do
    {:ok, Kura.Statistics.dashboard_stats(current_user.id)}
  end
end
