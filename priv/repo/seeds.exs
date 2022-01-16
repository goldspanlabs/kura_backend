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

  def random_symbol() do
    stock_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

    Enum.reduce(0..3, "", fn _, acc ->
      acc <> (stock_chars |> String.at(Enum.random(0..25)))
    end)
  end

  def generate_random_trade_dates() do
    current_date = Date.utc_today()
    rand_num = Enum.random(-180..1)
    start_date = Date.add(current_date, rand_num) |> Date.beginning_of_week()
    end_date = Date.add(start_date, Enum.random(1..rand_num)) |> Date.end_of_week(:saturday)

    {start_date, end_date}
  end

  def single(account_id, symbol, entry_date, exit_date, option_type \\ "C") do
    strike = Enum.random(10..100)
    price = round(strike * 0.1 * 100) / 100
    quantity = Enum.random(1..10)
    fee = round((9.99 + quantity * 1.25) * 100) / 100

    {:ok, formatted_date} = Timex.format(exit_date, "{D} {Mshort} {YY}")
    symbol = "#{symbol} #{formatted_date} #{strike} #{option_type}"

    insert_transaction(%{
      symbol: symbol,
      trade_date: entry_date,
      price: price,
      fee: fee,
      quantity: quantity,
      asset_type: "option",
      action: "BTO",
      expiration: exit_date,
      strike: strike,
      option_type: option_type,
      strategy_id: "single",
      trading_account_id: account_id
    })

    insert_transaction(%{
      symbol: symbol,
      trade_date: exit_date,
      price: price,
      fee: fee,
      quantity: quantity,
      asset_type: "option",
      action: "BTC",
      expiration: exit_date,
      strike: strike,
      option_type: option_type,
      strategy_id: "single",
      trading_account_id: account_id
    })
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
      {start_date, end_date} = generate_random_trade_dates()
      single(account.id, random_symbol(), start_date, end_date)
    end)
  end
end

Seeds.run()
