defmodule KuraBackendWeb.Resolvers.TradingAccount do
  alias KuraBackend.TradingAccounts

  def list_trading_accounts(_root, %{user_id: user_id}, _info) do
    {:ok, TradingAccounts.list_trading_accounts(user_id)}
  end
end
