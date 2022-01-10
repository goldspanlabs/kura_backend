defmodule KuraBackend.Transactions do
  @moduledoc """
  The Transactions context.
  """

  import Ecto.Query, warn: false
  import KuraBackend.Query

  alias KuraBackend.Repo

  alias KuraBackend.Transactions.Transaction
  alias KuraBackend.Strategies.Strategy
  alias KuraBackend.TradingAccounts.TradingAccount

  @doc """
  Returns the list of transactions.

  ## Examples

      iex> list_transactions()
      [%Transaction{}, ...]

  """
  def list_transactions do
    Repo.all(Transaction)
  end

  def list_transactions_with_costs(user_id) do
    Transaction
    |> join(:inner, [t], s in Strategy, as: :s, on: s.id == t.strategy_id)
    |> join(:inner, [t, _], a in TradingAccount, as: :a, on: a.id == t.trading_account_id)
    |> select([t, s: s, a: a], %{
      id: t.id,
      symbol: t.symbol,
      strategy: s.label,
      trade_date: t.trade_date,
      price: t.price,
      fee: t.fee,
      quantity: t.quantity,
      total_cost:
        case_when(t.asset_type == "option",
          do: t.price * t.quantity * 100 + t.fee,
          else: t.price + t.quantity + t.fee
        ),
      asset_type: t.asset_type,
      action: t.action,
      trading_account_id: t.trading_account_id,
      trading_account_name: a.name
    })
    |> where([a: a], a.user_id == ^user_id)
    |> Repo.all()
  end

  @doc """
  Gets a single transaction.

  Raises `Ecto.NoResultsError` if the Transaction does not exist.

  ## Examples

      iex> get_transaction!(123)
      %Transaction{}

      iex> get_transaction!(456)
      ** (Ecto.NoResultsError)

  """
  def get_transaction!(id), do: Repo.get!(Transaction, id)

  @doc """
  Creates a transaction.

  ## Examples

      iex> create_transaction(%{field: value})
      {:ok, %Transaction{}}

      iex> create_transaction(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_transaction(attrs \\ %{}) do
    %Transaction{}
    |> Transaction.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a transaction.

  ## Examples

      iex> update_transaction(transaction, %{field: new_value})
      {:ok, %Transaction{}}

      iex> update_transaction(transaction, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_transaction(%Transaction{} = transaction, attrs) do
    transaction
    |> Transaction.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a transaction.

  ## Examples

      iex> delete_transaction(transaction)
      {:ok, %Transaction{}}

      iex> delete_transaction(transaction)
      {:error, %Ecto.Changeset{}}

  """
  def delete_transaction(%Transaction{} = transaction) do
    Repo.delete(transaction)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking transaction changes.

  ## Examples

      iex> change_transaction(transaction)
      %Ecto.Changeset{data: %Transaction{}}

  """
  def change_transaction(%Transaction{} = transaction, attrs \\ %{}) do
    Transaction.changeset(transaction, attrs)
  end
end
