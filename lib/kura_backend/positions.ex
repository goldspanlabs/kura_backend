defmodule KuraBackend.Positions do
  import Ecto.Query, warn: false

  alias KuraBackend.Repo
  alias KuraBackend.Transactions.Transaction
  alias KuraBackend.TradingAccounts.TradingAccount
  alias KuraBackend.Strategies.Strategy

  defp base(user_id) do
    Transaction
    |> join(:inner, [t], a in TradingAccount, on: t.trading_account_id == a.id)
    |> join(:inner, [t], s in Strategy, on: t.strategy_id == s.id)
    |> where([t, _, _ ], t.user_id == ^user_id)
    |> select([t, a, s], %{
      strategy: s.label,
      symbol: t.symbol,
      block:
        fragment("regexp_matches(?, '^(.+) (\d{1,2} [a-zA-Z]{3} \d{2}) (\d+) ([PC])$')", t.symbol),
      action: t.action,
      asset_type: t.asset_type,
      trade_date: t.trade_date,
      fee: t.fee,
      price: t.price,
      quantity: t.quantity,
      trading_account_name: a.name,
      trading_account_id: a.id
    })
  end

  defp options(queryable) do
    queryable
    |> where([b], b.asset_type == "option")
    |> select_merge([b], %{
      total_cost: b.price * b.quantity * 100 + b.fee,
      expiration: fragment("to_date(?, 'DD MMM YY')", b.block[2]),
      strike: b.block[3],
      option_type: b.block[4]
    })
  end

  defp stocks(queryable) do
    queryable
    |> where([b], b.asset_type == "option")
    |> select_merge([b], %{
      total_cost: b.price * b.quantity + b.fee,
      expiration: nil,
      option_type: nil,
      strike: nil
    })
  end

  def normalize(user_id) do
    option = base(user_id) |> options()
    stock = base(user_id) |> stocks()
    option |> union(^stock)
  end

  def open_positions(user_id) do
    normalize(user_id) |> Repo.all()
  end

  def closed_positions(user_id) do
    normalize(user_id) |> Repo.all()
  end
end
