# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     KuraBackend.Repo.insert!(%KuraBackend.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

defmodule Seeds do
  alias KuraBackend.Accounts.User
  alias KuraBackend.TradingAccounts.TradingAccount
  alias KuraBackend.Strategies.Strategy
  alias KuraBackend.Transactions.Transaction
  alias KuraBackend.Repo

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

    strategy = insert_strategy(%{label: "Covered Call", legs: 2})
    strategy_2 = insert_strategy(%{label: "Short Call", legs: 1})

    user = insert_user(%{email: "test@example.com", password: "123456789012"})
    user_2 = insert_user(%{email: "test2@example.com", password: "123456789012"})

    account = insert_trading_account(%{name: "MARGIN", currency: "USD", user_id: user.id})
    account_2 = insert_trading_account(%{name: "MARGIN", currency: "USD", user_id: user_2.id})

    [
      %{
        symbol: "ABCD",
        trade_date: ~D[2022-01-01],
        price: 10.00,
        fee: 9.99,
        quantity: 100,
        asset_type: "stock",
        action: "BTO",
        strategy_id: strategy.id,
        trading_account_id: account.id
      },
      %{
        symbol: "ABCD",
        trade_date: ~D[2022-01-01],
        price: 1.00,
        fee: 11.24,
        quantity: 1,
        asset_type: "option",
        action: "STO",
        expiration: ~D[2022-01-31],
        strike: 15,
        option_type: "C",
        strategy_id: strategy.id,
        trading_account_id: account.id
      },
      %{
        symbol: "ABCD",
        trade_date: ~D[2022-01-01],
        price: 1.00,
        fee: 11.24,
        quantity: 1,
        asset_type: "option",
        action: "STO",
        expiration: ~D[2022-01-31],
        strike: 15,
        option_type: "P",
        strategy_id: strategy_2.id,
        trading_account_id: account.id
      },
      %{
        symbol: "ABCD",
        trade_date: ~D[2022-01-01],
        price: 10.00,
        fee: 9.99,
        quantity: 100,
        asset_type: "stock",
        action: "BTO",
        strategy_id: strategy.id,
        trading_account_id: account_2.id
      },
      %{
        symbol: "ABCD",
        trade_date: ~D[2022-01-01],
        price: 1.00,
        fee: 11.24,
        quantity: 1,
        asset_type: "option",
        action: "STO",
        expiration: ~D[2022-01-31],
        strike: 15,
        option_type: "C",
        strategy_id: strategy.id,
        trading_account_id: account_2.id
      },
      %{
        symbol: "ABCD",
        trade_date: ~D[2022-01-01],
        price: 1.00,
        fee: 11.24,
        quantity: 1,
        asset_type: "option",
        action: "STO",
        expiration: ~D[2022-01-31],
        strike: 15,
        option_type: "P",
        strategy_id: strategy_2.id,
        trading_account_id: account_2.id
      }
    ]
    |> Enum.each(fn attr ->
      insert_transaction(attr)
    end)
  end
end

Seeds.run()
