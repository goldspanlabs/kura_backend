defmodule KuraBackend.Charts do
  import Ecto.Query, warn: false
  import KuraBackend.Query

  alias KuraBackend.Repo
  alias KuraBackend.Positions

  defp base(user_id) do
    subquery(Positions.do_closed_positions(user_id))
    |> select([p], %{
      period:
        fragment(
          "to_char(generate_series(date_trunc('month', min(?)),
          (date_trunc('month', max(?)) + interval '1 month - 1 day')::DATE, 
          interval '1 day')::DATE, 'MM')",
          p.exit_date,
          p.exit_date
        ),
      realized_pnl: 0,
      strategy: p.strategy
    })
    |> group_by([p], p.strategy)
  end

  defp series(user_id) do
    subquery(Positions.do_closed_positions(user_id))
    |> select([p], %{
      period: fragment("to_char(?, 'MM')", p.exit_date),
      realized_pnl: sum(p.realized_pnl),
      strategy: p.strategy
    })
    |> where(
      [p],
      p.exit_date >= fragment("date_trunc('month', now() - interval '5 month')::DATE") and
        p.exit_date <= fragment("NOW()")
    )
    |> group_by([p], [
      fragment("to_char(?, 'MM')", p.exit_date),
      fragment("to_char(?, 'Mon')", p.exit_date),
      p.strategy
    ])
    |> order_by([p], [
      fragment("to_char(?, 'MM')", p.exit_date),
      fragment("to_char(?, 'Mon')", p.exit_date),
      p.strategy
    ])
  end

  defp base_series_union(user_id) do
    query = subquery(series(user_id))

    subquery(base(user_id))
    |> union_all(^query)
    |> select([u], %{period: u.period, realized_pnl: u.realized_pnl, strategy: u.strategy})
  end

  defp comp_base(user_id) do
    subquery(Positions.do_closed_positions(user_id))
    |> select([p], %{
      exit_date:
        fragment(
          "generate_series(date_trunc('month', min(?)),
          (date_trunc('month', max(?)) + interval '1 month - 1 day')::DATE, 
          interval '1 day')::DATE",
          p.exit_date,
          p.exit_date
        ),
      realized_pnl: 0
    })
  end

  defp comp_series(user_id) do
    subquery(comp_base(user_id))
    |> join(:left, [b], cp in subquery(Positions.do_closed_positions(user_id)),
      on: cp.exit_date == b.exit_date
    )
    |> select([b, cp], %{
      exit_date: b.exit_date,
      grouped_realized_pnl: sum(b.realized_pnl + coalesce(cp.realized_pnl, 0))
    })
    |> where(
      [b],
      b.exit_date >= fragment("date_trunc('month', now() - interval '1 month')::DATE") and
        b.exit_date <= fragment("NOW()")
    )
    |> group_by([b], [b.exit_date])
    |> order_by([b], [b.exit_date])
  end

  def comp_series_sub(user_id) do
    subquery(comp_series(user_id))
    |> select([ss], %{
      exit_date: ss.exit_date,
      grouped_realized_pnl: sum(ss.grouped_realized_pnl),
      ea_month: fragment("to_char(?, 'Month')", ss.exit_date)
    })
    |> group_by([ss], [ss.exit_date, fragment("to_char(?, 'Month')", ss.exit_date)])
  end

  def pnl_comp_chart(user_id) do
    subquery(comp_series_sub(user_id))
    |> select([ss], %{
      exit_date: ss.exit_date,
      cumulated_pnl:
        fragment(
          "SUM(?) OVER (PARTITION BY ? ORDER BY ?)",
          ss.grouped_realized_pnl,
          ss.ea_month,
          ss.exit_date
        ),
      period:
        case_when(
          fragment("extract(MONTH from ?)", ss.exit_date) ==
            fragment("extract(MONTH from NOW())"),
          do: "CURRENT_MONTH",
          else: "PREVIOUS_MONTH"
        ),
      day: fragment("extract(DAY from ?)", ss.exit_date)
    })
    |> order_by([ss], ss.exit_date)
    |> Repo.all()
  end

  def pnl_chart(user_id) do
    subquery(base_series_union(user_id))
    |> select([u], %{period: u.period, realized_pnl: sum(u.realized_pnl), strategy: u.strategy})
    |> group_by([u], [u.period, u.strategy])
    |> order_by([u], [u.period, u.strategy])
    |> Repo.all()
  end
end
