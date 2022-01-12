defmodule Kura.Statistics do
  import Ecto.Query, warn: false
  import Kura.Query

  alias Kura.{Transactions.Transaction, TradingAccounts.TradingAccount, Positions, Repo}

  defp total_pnl(user_id) do
    subquery(Positions.do_closed_positions(user_id))
    |> select([cp], sum(cp.realized_pnl * -1))
    |> Repo.one()
    |> case do
      nil -> Decimal.new(0)
      tp -> Decimal.new(tp)
    end
  end

  defp avg_pnl(user_id) do
    subquery(Positions.do_closed_positions(user_id))
    |> select([cp], round(avg(cp.realized_pnl), 2) * -1)
    |> Repo.one()
    |> case do
      nil -> Decimal.new(0)
      ap -> Decimal.new(ap)
    end
  end

  defp total_fees(user_id) do
    Transaction
    |> join(:inner, [t], a in TradingAccount, on: t.trading_account_id == a.id)
    |> where([t, a], a.user_id == ^user_id)
    |> select([t], sum(t.fee))
    |> Repo.one()
    |> case do
      nil -> Decimal.new(0)
      tf -> Decimal.new(tf)
    end
  end

  defp win_count(user_id) do
    subquery(Positions.do_closed_positions(user_id))
    |> select([], count())
    |> where([cp], cp.realized_pnl < 0)
    |> Repo.one()
    |> Decimal.new()
  end

  defp total_count(user_id) do
    subquery(Positions.do_closed_positions(user_id))
    |> select([cp], count())
    |> Repo.one()
    |> Decimal.new()
  end

  defp win_rate(user_id) do
    if Decimal.compare(total_count(user_id), 0) == :eq,
      do: Decimal.new(0),
      else: Decimal.div(win_count(user_id), total_count(user_id)) |> Decimal.mult(100)
  end

  def dashboard_stats(user_id) do
    %{
      total_pnl: total_pnl(user_id),
      total_fees: total_fees(user_id),
      avg_pnl: avg_pnl(user_id),
      win_rate: win_rate(user_id)
    }
  end
end
