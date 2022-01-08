defmodule KuraBackendWeb.Schema.UserTypes do
  use Absinthe.Schema.Notation

  alias KuraBackendWeb.Resolvers

  @desc "A user"
  object :user do
    field :email, :string
    field :id, :id
  end

  object :create_user_mutation do
    @desc """
    create user
    """

    @desc "Create a user"
    field :sign_up, :user do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))

      resolve(&Resolvers.Accounts.create_user/3)
    end
  end

  object :session_mutation do
    @desc """
    login with the params
    """

    field :login, :session do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))
      resolve(&Resolvers.Accounts.login/2)
    end
  end

  @desc "session value"
  object :session do
    field(:token, :string)
    field(:user, :user)
  end
end
