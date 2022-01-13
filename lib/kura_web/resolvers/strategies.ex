defmodule KuraWeb.Resolvers.Strategies do
  def get_strategy(_, %{strategy_id: strategy_id}, _context) do
    {:ok, Kura.Strategies.get_strategy(strategy_id)}
  end
end
