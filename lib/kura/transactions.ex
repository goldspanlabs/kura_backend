defmodule Kura.Transactions do
  @moduledoc """
  The Transactions context.
  """

  import Ecto.Query, warn: false
  import Kura.Query

  alias Kura.Repo

  alias Kura.Transactions.Transaction
  alias Kura.Strategies.Strategy
  alias Kura.TradingAccounts.TradingAccount

  @doc """
  Returns the list of transactions.

  ## Examples

      iex> list_transactions()
      [%Transaction{}, ...]

  """

  def list_transactions(user_id, nil) do
    do_list_transactions(user_id)
    |> Repo.all()
  end

  def list_transactions(user_id, limit) do
    do_list_transactions(user_id)
    |> limit(^limit)
    |> Repo.all()
  end

  def strategy_details(user_id, root, strategy_id) do
    do_list_transactions(user_id)
    |> where([t], ilike(t.symbol, ^"#{root}%"))
    |> where([s: s], s.id == ^strategy_id)
    |> Repo.all()
  end

  defp do_list_transactions(user_id) do
    Transaction
    |> join(:inner, [t], s in Strategy, as: :s, on: s.id == t.strategy_id)
    |> join(:inner, [t, _], a in TradingAccount, as: :a, on: a.id == t.trading_account_id)
    |> select([t, s: s, a: a], %{
      id: t.id,
      symbol: t.symbol,
      strategy: s.label,
      strategy_id: t.strategy_id,
      trade_date: t.trade_date,
      price: t.price,
      fee: t.fee,
      quantity: t.quantity,
      total_cost:
        case_when(t.asset_type == "option",
          do: t.price * t.quantity * 100 + t.fee,
          else: t.price * t.quantity + t.fee
        ),
      asset_type: t.asset_type,
      option_type: t.option_type,
      expiration: t.expiration,
      strike: t.strike,
      action: t.action,
      trading_account_id: t.trading_account_id,
      trading_account_name: a.name
    })
    |> where([a: a], a.user_id == ^user_id)
    |> order_by([t], desc: t.trade_date)
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
  def get_transaction(id), do: Repo.get(Transaction, id)

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
    |> Transaction.update_changeset(attrs)
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

  def upload_transactions(account_id, file) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    data =
      file.path
      |> File.stream!()
      |> CSV.decode(headers: true)
      |> Enum.map(fn {:ok, row} ->
        data_row =
          Enum.reject(row, fn {_k, v} -> v == "" end)
          |> Map.new(fn {k, v} ->
            {String.to_existing_atom(k), parse_value(k, v)}
          end)
          |> Map.put(:trading_account_id, account_id)
          |> Map.put(:inserted_at, now)
          |> Map.put(:updated_at, now)

        if Map.has_key?(data_row, :expiration) do
          {:ok, formatted_date} = Timex.format(data_row.expiration, "{D} {Mshort} {YY}")

          symbol =
            "#{data_row.symbol} #{formatted_date} #{data_row.strike} #{data_row.option_type}"

          Map.merge(data_row, %{symbol: symbol, strategy_id: data_row.strategy})
          |> Map.drop([:strategy])
        else
          data_row
          |> Map.put(:strategy_id, data_row.strategy)
          |> Map.drop([:strategy])
        end
      end)

    Repo.insert_all(Transaction, data)
  end

  defp parse_value(key, value) when key in ["trade_date", "expiration"],
    do: Date.from_iso8601!(value)

  defp parse_value(key, value) when key in ["price", "fee", "strike"],
    do: Decimal.new(value)

  defp parse_value(key, value) when key == "quantity",
    do: String.to_integer(value)

  defp parse_value(_key, value), do: value
end
