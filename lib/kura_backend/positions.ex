defmodule KuraBackend.Positions do
  import Ecto.Query, warn: false

  alias KuraBackend.Repo
  alias KuraBackend.Transactions.Transaction
  alias KuraBackend.TradingAccounts.TradingAccount
  alias KuraBackend.Strategies.Strategy

  def base(user_id) do
    Transaction
    |> join(:inner, [t], a in TradingAccount, on: t.trading_account_id == a.id)
    |> join(:inner, [t], s in Strategy, on: t.strategy_id == s.id)
    |> where([_, a, _], a.user_id == ^user_id)
    |> select([t, a, s], %{
      strategy: s.label,
      symbol: t.symbol,
      action: t.action,
      asset_type: t.asset_type,
      trade_date: t.trade_date,
      fee: t.fee,
      price: t.price,
      quantity: t.quantity,
      total_cost:
        fragment(
          "CASE WHEN ? = 'option' THEN (? * ? * 100) + ? ELSE (? * ?) + ? END",
          t.asset_type,
          t.price,
          t.quantity,
          t.fee,
          t.price,
          t.quantity,
          t.fee
        ),
      trading_account_name: a.name,
      trading_account_id: a.id
    })
  end

  def open_positions(user_id) do
    base(user_id) |> Repo.all()
  end

  def closed_positions(user_id) do
    base(user_id) |> Repo.all()
  end
end
