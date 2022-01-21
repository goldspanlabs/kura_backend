defmodule Kura.Charts.PnlChart do
  import Ecto.Query, warn: false
  import ShorterMaps

  alias Kura.Repo
  alias Kura.{Positions, Strategies}

  def trade_range(user_id) do
    subquery(Positions.do_closed_positions(user_id))
    |> select([p], %{min: min(p.entry_date), max: max(p.exit_date)})
  end

  def trade_base(user_id) do
    subquery(trade_range(user_id))
    |> join(:cross, [t], s in subquery(Strategies.get_user_strategies(user_id)))
    |> select([t, s], %{
      period:
        fragment(
          "generate_series(date_trunc('month', min(?)),
          (date_trunc('month', max(?)) + interval '1 month - 1 day')::DATE,
          interval '1 day')::DATE",
          t.min,
          t.max
        ),
      period_label:
        fragment(
          "to_char(generate_series(date_trunc('month', min(?)),
          (date_trunc('month', max(?)) + interval '1 month - 1 day')::DATE,
          interval '1 day')::DATE, 'Mon')",
          t.min,
          t.max
        ),
      realized_pnl: 0.00,
      strategy: s.strategy
    })
    |> group_by([t, s], [s.strategy])
  end

  def trade_base_grouped(user_id) do
    subquery(trade_base(user_id))
    |> select([b], %{
      period_label: b.period_label,
      period: b.period,
      realized_pnl: b.realized_pnl,
      strategy: b.strategy
    })
    |> order_by([b], [b.period, b.strategy])
  end

  def series(user_id) do
    subquery(Positions.do_closed_positions(user_id))
    |> select([p], %{
      period_label: fragment("to_char(?::DATE, 'Mon')", p.exit_date),
      period: p.exit_date,
      realized_pnl: sum(p.realized_pnl),
      strategy: p.strategy
    })
    |> where(
      [p],
      p.exit_date >= fragment("date_trunc('month', now() - interval '5 month')::DATE") and
        p.exit_date <= fragment("NOW()")
    )
    |> group_by([p], [p.exit_date, p.strategy])
    |> order_by([p], [p.exit_date, p.strategy])
  end

  def base_series_union(user_id) do
    query = subquery(series(user_id))

    subquery(trade_base_grouped(user_id))
    |> union_all(^query)
    |> select([u], %{
      period_label: u.period_label,
      period: u.period,
      realized_pnl: u.realized_pnl,
      strategy: u.strategy
    })
  end

  def generate(user_id) do
    chart_data =
      subquery(base_series_union(user_id))
      |> select([u], %{
        period_label: u.period_label,
        period: max(u.period),
        realized_pnl: sum(u.realized_pnl),
        strategy: u.strategy
      })
      |> group_by([u], [u.period_label, u.strategy])
      |> order_by([u], [max(u.period), u.strategy])
      |> Repo.all()

    categories = chart_data |> Enum.map(& &1.period_label) |> Enum.uniq()

    series =
      chart_data
      |> Enum.group_by(
        & &1.strategy,
        &(Float.to_string(&1.realized_pnl) |> Decimal.new() |> Decimal.round(0))
      )
      |> Enum.map(fn {name, data} -> ~M{name, data} end)

    %{categories: categories, series: series}
  end
end
