defmodule KuraWeb.Resolvers.Transactions do
  alias Kura.Transactions.Transaction
  alias Kura.Transactions
  use Timex

  def strategy_details(_, %{root: root, strategy_id: strategy_id}, %{
        context: %{current_user: current_user}
      }) do
    {:ok, Transactions.strategy_details(current_user.id, root, strategy_id)}
  end

  def list_transactions(_, args, %{context: %{current_user: current_user}}) do
    {:ok, Transactions.list_transactions(current_user.id, Map.get(args, :limit))}
  end

  def insert_transaction_one(_, %{object: object}, _) do
    case Transactions.create_transaction(object) do
      {:ok, transaction} -> {:ok, transaction}
      _error -> {:error, "error inserting transaction"}
    end
  end

  def update_transaction_by_pk(_, %{id: id, object: object}, _) do
    with %Transaction{} = transaction <- Transactions.get_transaction(id),
         {:ok, %Transaction{}} <- Transactions.update_transaction(transaction, object) do
      {:ok, transaction}
    else
      _error -> {:error, "error updating transaction"}
    end
  end

  def delete_transaction_by_pk(_, %{id: id}, _) do
    with %Transaction{} = transaction <- Transactions.get_transaction(id),
         {:ok, %Transaction{}} <- Transactions.delete_transaction(transaction) do
      {:ok, transaction}
    else
      _error -> {:error, "error deleting transaction"}
    end
  end

  def file_upload(_, %{file: file, account_id: account_id}, _) do
    with {num_entries, _} <- Transactions.upload_transactions(account_id, file) do
      {:ok, num_entries}
    else
      _error -> {:error, "error uploading transactions"}
    end
  end
end
