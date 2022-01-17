defmodule Kura.Positions do
  import Ecto.Query, warn: false
  import Kura.Query

  alias Kura.Repo
  alias Kura.Transactions.Transaction
  alias Kura.TradingAccounts.TradingAccount
  alias Kura.Strategies.Strategy

  defp base(user_id) do
    Transaction
    |> join(:inner, [t], a in TradingAccount, as: :a, on: t.trading_account_id == a.id)
    |> join(:inner, [t], s in Strategy, as: :s, on: t.strategy_id == s.id)
    |> where([a: a], a.user_id == ^user_id)
    |> select([t, a: a, s: s], %{
      strategy: s.label,
      strategy_id: t.strategy_id,
      symbol: t.symbol,
      action: t.action,
      asset_type: t.asset_type,
      trade_date: t.trade_date,
      fee: t.fee,
      price: t.price,
      quantity: t.quantity,
      expiration: t.expiration,
      strike: t.strike,
      option_type: t.option_type,
      total_cost:
        case_when(t.asset_type == "option",
          do: t.price * t.quantity * 100 + t.fee,
          else: t.price * t.quantity + t.fee
        ),
      trading_account_name: a.name,
      trading_account_id: a.id
    })
  end

  def trades(user_id) do
    subquery(base(user_id))
    |> select([b], %{
      strategy: b.strategy,
      strategy_id: b.strategy_id,
      symbol: b.symbol,
      root: fragment("split_part(?, ' ', 1)", b.symbol),
      action: b.action,
      asset_type: b.asset_type,
      trade_date: b.trade_date,
      fee: b.fee,
      price: b.price,
      quantity: b.quantity,
      expiration: b.expiration,
      strike: b.strike,
      option_type: b.option_type,
      total_cost: b.total_cost,
      adjusted_price:
        case_when(b.asset_type == "option",
          do: b.total_cost / 100 / b.quantity,
          else: b.total_cost / b.quantity
        ),
      trading_account_name: b.trading_account_name,
      trading_account_id: b.trading_account_id
    })
  end

  def open_pos(user_id) do
    subquery(trades(user_id))
    |> select([t], %{
      symbol: t.symbol,
      root: t.root,
      strategy: t.strategy,
      strategy_id: t.strategy_id,
      expiration: t.expiration,
      option_type: t.option_type,
      strike: t.strike,
      asset_type: t.asset_type,
      trading_account_name: t.trading_account_name,
      trading_account_id: t.trading_account_id
    })
    |> group_by([t], [
      t.symbol,
      t.root,
      t.strategy,
      t.strategy_id,
      t.expiration,
      t.option_type,
      t.strike,
      t.asset_type,
      t.trading_account_name,
      t.trading_account_id
    ])
    |> having([t], sum(t.quantity) != 0)
  end

  defp open_averages(user_id) do
    subquery(trades(user_id))
    |> join(:inner, [t], op in subquery(open_pos(user_id)), on: op.symbol == t.symbol)
    |> select([b], %{
      symbol: b.symbol,
      root: b.root,
      strategy: b.strategy,
      strategy_id: b.strategy_id,
      expiration: b.expiration,
      option_type: b.option_type,
      strike: b.strike,
      asset_type: b.asset_type,
      trading_account_name: b.trading_account_name,
      trading_account_id: b.trading_account_id,
      avg_price: fragment("round(weighted_avg(?, ?)::NUMERIC, 2)", b.adjusted_price, b.quantity)
    })
    |> group_by([b], [
      b.symbol,
      b.root,
      b.strategy,
      b.strategy_id,
      b.expiration,
      b.option_type,
      b.strike,
      b.asset_type,
      b.expiration,
      b.option_type,
      b.strike,
      b.option_type,
      b.trading_account_name,
      b.trading_account_id
    ])
  end

  defp grouped_trades(user_id) do
    subquery(trades(user_id))
    |> select([t], %{
      symbol: t.symbol,
      strategy: t.strategy,
      action: t.action,
      expiration: t.expiration,
      option_type: t.option_type,
      strike: t.strike,
      asset_type: t.asset_type,
      trading_account_name: t.trading_account_name,
      trading_account_id: t.trading_account_id,
      trade_date: max(t.trade_date),
      quantity: sum(t.quantity),
      total_cost: sum(t.total_cost),
      fee: sum(t.fee)
    })
    |> group_by([t], [
      t.symbol,
      t.strategy,
      t.action,
      t.expiration,
      t.option_type,
      t.strike,
      t.asset_type,
      t.trading_account_name,
      t.trading_account_id
    ])
  end

  def do_open_positions(user_id) do
    subquery(open_averages(user_id))
    |> join(:inner, [oa], t in subquery(trades(user_id)), on: t.symbol == oa.symbol)
    |> select([oa, t], %{
      symbol: oa.symbol,
      root: oa.root,
      strategy: oa.strategy,
      strategy_id: oa.strategy_id,
      asset_type: oa.asset_type,
      trade_date: max(t.trade_date),
      expiration: oa.expiration,
      strike: oa.strike,
      option_type: oa.option_type,
      quantity: sum(t.quantity),
      avg_price: oa.avg_price,
      book_cost: sum(t.total_cost),
      days_from_expiration: sum(oa.expiration - t.trade_date),
      days_to_expiration:
        fragment("(EXTRACT(epoch FROM (SELECT (? - now()))) / 86400)::INT", oa.expiration),
      asset_type: oa.asset_type,
      trading_account_id: oa.trading_account_id,
      trading_account_name: oa.trading_account_name
    })
    |> group_by([oa, t], [
      oa.symbol,
      oa.root,
      oa.strategy,
      oa.strategy_id,
      oa.asset_type,
      oa.avg_price,
      oa.expiration,
      oa.option_type,
      oa.strike,
      oa.asset_type,
      oa.trading_account_id,
      oa.trading_account_name
    ])
    |> order_by([_, t], desc: max(t.trade_date))
  end

  def do_closed_positions(user_id) do
    subquery(trades(user_id))
    |> join(:inner, [t], t2 in subquery(grouped_trades(user_id)),
      on:
        t.symbol == t2.symbol and t.strategy == t2.strategy and
          t.trading_account_id == t2.trading_account_id
    )
    |> select([t, t2], %{
      symbol: t.symbol,
      strategy: t.strategy,
      expiration: t.expiration,
      entry_date: t.trade_date,
      exit_date: t2.trade_date,
      days_in_trade: t2.trade_date - t.trade_date,
      entry_cost: t.total_cost,
      exit_cost: t2.total_cost,
      total_fees: t.fee + t2.fee,
      realized_pnl: t.total_cost + t2.total_cost,
      trading_account_id: t.trading_account_id,
      trading_account_name: t.trading_account_name
    })
    |> where(
      [t, t2],
      (t.action == "BTO" or t.action == "STO") and (t2.action != "BTO" and t2.action != "STO")
    )
    |> order_by([_, t2], desc: t2.trade_date)
  end

  def open_positions(user_id) do
    do_open_positions(user_id) |> Repo.all()
  end

  def closed_positions(user_id) do
    do_closed_positions(user_id) |> Repo.all()
  end
end
