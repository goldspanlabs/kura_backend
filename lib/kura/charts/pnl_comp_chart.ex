defmodule Kura.Charts.PnlCompChart do
  import Ecto.Query, warn: false
  import Kura.Query
  import ShorterMaps

  alias Kura.Repo
  alias Kura.Positions

  def comp_base(user_id) do
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
      realized_pnl: 0.00
    })
  end

  def comp_series(user_id) do
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

  def generate(user_id) do
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
    |> Enum.map(fn ~M{cumulated_pnl, exit_date, period} ->
      ~M{cumulated_pnl: Float.to_string(cumulated_pnl) |> Decimal.new() |> Decimal.round(), exit_date, period}
    end)
  end
end
