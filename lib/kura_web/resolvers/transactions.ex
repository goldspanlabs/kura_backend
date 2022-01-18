defmodule KuraWeb.Resolvers.Transactions do
  alias Kura.Transactions.Transaction
  alias Kura.Repo
  use Timex

  def strategy_details(_, %{root: root, strategy_id: strategy_id}, %{
        context: %{current_user: current_user}
      }) do
    {:ok, Kura.Transactions.strategy_details(current_user.id, root, strategy_id)}
  end

  def list_transactions(_, args, %{context: %{current_user: current_user}}) do
    {:ok, Kura.Transactions.list_transactions(current_user.id, Map.get(args, :limit))}
  end

  def insert_transaction_one(_, %{object: object}, _) do
    case Kura.Transactions.create_transaction(object) do
      {:ok, transaction} -> {:ok, transaction}
      _error -> {:error, "error inserting transaction"}
    end
  end

  def update_transaction_by_pk(_, %{id: id, object: object}, _) do
    with %Transaction{} = transaction <- Kura.Transactions.get_transaction(id),
         {:ok, %Transaction{}} <- Kura.Transactions.update_transaction(transaction, object) do
      {:ok, transaction}
    else
      _error -> {:error, "error updating transaction"}
    end
  end

  def delete_transaction_by_pk(_, %{id: id}, _) do
    with %Transaction{} = transaction <- Kura.Transactions.get_transaction(id),
         {:ok, %Transaction{}} <- Kura.Transactions.delete_transaction(transaction) do
      {:ok, transaction}
    else
      _error -> {:error, "error deleting transaction"}
    end
  end

  def file_upload(_, %{file: file, account_id: account_id}, _) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    data =
      file.path
      |> File.stream!()
      |> CSV.decode(headers: true)
      |> Enum.map(fn {:ok, row} ->
        data_row =
          Enum.reject(row, fn {_k, v} -> v == "" end)
          |> Map.new(fn {k, v} ->
            v =
              cond do
                k == "trade_date" ->
                  Date.from_iso8601!(v)

                k == "expiration" ->
                  Date.from_iso8601!(v)

                k == "price" ->
                  Decimal.new(v)

                k == "fee" ->
                  Decimal.new(v)

                k == "strike" ->
                  Decimal.new(v)

                k == "quantity" ->
                  String.to_integer(v)

                true ->
                  v
              end

            {String.to_existing_atom(k), v}
          end)
          |> Map.put(:trading_account_id, account_id)
          |> Map.put(:inserted_at, now)
          |> Map.put(:updated_at, now)

        if Map.has_key?(data_row, :expiration) do
          {:ok, formatted_date} = Timex.format(data_row.expiration, "{D} {Mshort} {YY}")

          symbol =
            "#{data_row.symbol} #{formatted_date} #{data_row.strike} #{data_row.option_type}"

          Map.merge(data_row, %{symbol: symbol})
        else
          data_row
        end
      end)

    Repo.insert_all(Transaction, data)

    {:ok, :success}
  end
end
