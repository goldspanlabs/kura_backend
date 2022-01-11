defmodule KuraWeb.Resolvers.Transactions do
  alias Kura.Transactions.Transaction

  def list_transactions(_, _, %{context: %{current_user: current_user}}) do
    {:ok, Kura.Transactions.list_transactions_with_costs(current_user.id)}
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
end
