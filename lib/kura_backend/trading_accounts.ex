defmodule KuraBackend.TradingAccounts do
  @moduledoc """
  The TradingAccounts context.
  """

  import Ecto.Query, warn: false
  alias KuraBackend.Repo

  alias KuraBackend.TradingAccounts.TradingAccount

  @doc """
  Returns the list of trading_accounts.

  ## Examples

      iex> list_trading_accounts()
      [%TradingAccount{}, ...]

  """
  def list_trading_accounts(user_id) do
    Repo.all(from ta in TradingAccount, where: ta.user_id == ^user_id)
  end

  @doc """
  Gets a single trading_account.

  Raises `Ecto.NoResultsError` if the Trading account does not exist.

  ## Examples

      iex> get_trading_account!(123)
      %TradingAccount{}

      iex> get_trading_account!(456)
      ** (Ecto.NoResultsError)

  """
  def get_trading_account!(id), do: Repo.get!(TradingAccount, id)

  @doc """
  Creates a trading_account.

  ## Examples

      iex> create_trading_account(%{field: value})
      {:ok, %TradingAccount{}}

      iex> create_trading_account(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_trading_account(attrs \\ %{}) do
    %TradingAccount{}
    |> TradingAccount.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a trading_account.

  ## Examples

      iex> update_trading_account(trading_account, %{field: new_value})
      {:ok, %TradingAccount{}}

      iex> update_trading_account(trading_account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_trading_account(%TradingAccount{} = trading_account, attrs) do
    trading_account
    |> TradingAccount.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a trading_account.

  ## Examples

      iex> delete_trading_account(trading_account)
      {:ok, %TradingAccount{}}

      iex> delete_trading_account(trading_account)
      {:error, %Ecto.Changeset{}}

  """
  def delete_trading_account(%TradingAccount{} = trading_account) do
    Repo.delete(trading_account)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking trading_account changes.

  ## Examples

      iex> change_trading_account(trading_account)
      %Ecto.Changeset{data: %TradingAccount{}}

  """
  def change_trading_account(%TradingAccount{} = trading_account, attrs \\ %{}) do
    TradingAccount.changeset(trading_account, attrs)
  end
end
