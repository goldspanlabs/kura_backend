defmodule KuraWeb.Resolvers.Accounts do
  alias Kura.Accounts
  alias Kura.Accounts.User

  def sign_up(_parent, args, _context) do
    with {:ok, %User{} = user} <- Accounts.register_user(args),
         {:ok, jwt, _full_claims} <- Kura.Guardian.encode_and_sign(user, %{}, ttl: {1, :hour}) do
      {:ok, %{token: jwt}}
    else
      _ -> {:error, "User exists"}
    end
  end

  def login(%{email: email, password: password}, _info) do
    with %User{} = user <- Accounts.get_user_by_email_and_password(email, password),
         {:ok, jwt, _full_claims} <- Kura.Guardian.encode_and_sign(user, %{}, ttl: {1, :hour}) do
      {:ok, %{token: jwt}}
    else
      _ -> {:error, "Incorrect email or password"}
    end
  end
end
