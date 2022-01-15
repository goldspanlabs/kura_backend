defmodule KuraWeb.Schema.UserTypes do
  use Absinthe.Schema.Notation

  alias KuraWeb.Resolvers

  @desc "Create a user"
  object :user_mutations do
    field :sign_up, :session do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))

      resolve(&Resolvers.Accounts.sign_up/3)
    end
  end

  @desc "login with the params"
  object :session_mutations do
    field :login, :session do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))
      resolve(&Resolvers.Accounts.login/2)
    end
  end

  @desc "session value"
  object :session do
    field(:token, :string)
  end
end
