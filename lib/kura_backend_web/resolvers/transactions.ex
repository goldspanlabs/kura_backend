defmodule KuraWeb.Resolvers.Transactions do
  def list_transactions(_, _, %{context: %{current_user: current_user}}) do
    {:ok, Kura.Transactions.list_transactions_with_costs(current_user.id)}
  end
end
