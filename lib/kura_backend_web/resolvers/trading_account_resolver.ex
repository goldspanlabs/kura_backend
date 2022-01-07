defmodule KuraBackendWeb.Resolvers.TradingAccount do
  alias KuraBackend.TradingAccounts

  def list_trading_accounts(_root, _args, _info) do
    {:ok, TradingAccounts.list_trading_accounts()}
  end
end
