# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Kura.Repo.insert!(%Kura.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

defmodule Seeds do
  alias Kura.Accounts.User
  alias Kura.TradingAccounts.TradingAccount
  alias Kura.Strategies.Strategy
  alias Kura.Transactions.Transaction
  alias Kura.Repo

  import ShorterMaps
  use Timex

  @option_strategies [
    {"single", "Single Option", 2},
    {"covered-stock", "Covered Stock", 2},
    {"straddle", "Straddle", 2},
    {"strangle", "Strangle", 2},
    {"vertical", "Vertical", 2},
    {"calendar", "Calendar", 2},
    {"butterfly", "Butterfly", 3},
    {"collar", "Collar(with stock)", 3},
    {"condor", "Condor", 4},
    {"iron-butterfly", "Iron Butterfly", 4},
    {"iron-condor", "Iron Condor", 4}
  ]

  def generate_random_symbol() do
    stock_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

    Enum.reduce(0..3, "", fn _, acc ->
      acc <> (stock_chars |> String.at(Enum.random(0..25)))
    end)
  end

  def generate_random_trade_dates() do
    current_date = Date.utc_today()
    rand_num = Enum.random(-90..0)
    start_date = Date.add(current_date, rand_num) |> Date.beginning_of_week()
    end_date = Date.add(start_date, Enum.random(0..30)) |> Date.end_of_week(:saturday)

    {start_date, end_date}
  end

  def generate_prices(quantity) do
    strike = Enum.random(15..200)
    fee = round((9.99 + quantity * 1.25) * 100) / 100
    entry_price = round(strike * 0.1 * 100) / 100
    exit_price = Enum.random(0..(round(entry_price) * 4))

    {entry_price, exit_price, fee, strike, strike + strike * Enum.random(-5..5) / 100}
  end

  def insert_strategy(attrs) do
    %Strategy{}
    |> Strategy.changeset(attrs)
    |> Repo.insert!()
  end

  def insert_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert!()
  end

  def insert_trading_account(attrs) do
    %TradingAccount{}
    |> TradingAccount.changeset(attrs)
    |> Repo.insert!()
  end

  def insert_transaction(attrs) do
    %Transaction{}
    |> Transaction.changeset(attrs)
    |> Repo.insert!()
  end

  def single(opts, :open) do
    do_single(opts, "BTO")

    if Date.compare(opts.exit_date, Date.utc_today()) == :lt do
      do_single(opts, "EXP")
    end
  end

  def single(opts, :close) do
    do_single(opts, "BTO")
    do_single(opts, "STC")
  end

  def do_single(opts, action) do
    trade_date = if action == "BTO" or action == "STO", do: opts.trade_date, else: opts.exit_date

    price = if action == "BTO" or action == "STO", do: opts.entry_price, else: opts.exit_price

    side =
      cond do
        action == "BTO" or action == "BTC" -> 1
        action == "STO" or action == "STC" -> -1
        true -> 0
      end

    insert_transaction(%{
      trading_account_id: opts.account_id,
      symbol: opts.symbol,
      trade_date: trade_date,
      quantity: opts.quantity * side,
      action: action,
      price: price,
      fee: opts.fee,
      strike: opts.strike,
      expiration: opts.exit_date,
      asset_type: "option",
      strategy_id: "single",
      option_type: opts.option_type
    })
  end

  def run do
    Repo.truncate(Transaction, :cascade)
    Repo.truncate(TradingAccount, :cascade)
    Repo.truncate(User, :cascade)
    Repo.truncate(Strategy, :cascade)

    Enum.each(@option_strategies, fn {id, label, legs} ->
      insert_strategy(~M{id, label, legs: legs})
    end)

    [
      %{email: "test@example.com", password: "123456789012"},
      %{email: "test2@example.com", password: "123456789012"}
    ]
    |> Enum.each(fn u ->
      user = insert_user(u)
      account = insert_trading_account(%{name: "MARGIN", currency: "USD", user_id: user.id})

      Enum.each(1..50, fn n ->
        {trade_date, exit_date} = generate_random_trade_dates()
        {strategy, _, _} = Enum.random(@option_strategies)
        quantity = Enum.random(1..10)
        {entry_price, exit_price, fee, strike, underlying_price} = generate_prices(quantity)
        option_type = Enum.random(["C", "P"])

        {:ok, formatted_date} = Timex.format(exit_date, "{D} {Mshort} {YY}")
        symbol = "#{generate_random_symbol()} #{formatted_date} #{strike} #{option_type}"

        position = if Date.compare(exit_date, Date.utc_today()) == :gt, do: :open, else: :close

        single(
          ~M{account_id: account.id, symbol, option_type, trade_date, exit_date, quantity, entry_price, exit_price, fee, strike, underlying_price},
          position
        )
      end)
    end)
  end
end

Seeds.run()
