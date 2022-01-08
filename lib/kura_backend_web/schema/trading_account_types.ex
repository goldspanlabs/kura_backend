defmodule KuraBackendWeb.Schema.TradingAccountTypes do
  use Absinthe.Schema.Notation

  alias KuraBackendWeb.Resolvers
  alias KuraBackendWeb.Schema.Middleware

  object :trading_account do
    field :id, non_null(:id)
    field :name, non_null(:string)
    field :currency, non_null(:string)
    field :user_id, non_null(:id)
  end

  @desc "List trading accounts"
  object :trading_accounts do
    field :trading_accounts, list_of(:trading_account) do
      arg(:user_id, non_null(:id))

      middleware(Middleware.Authorize)
      resolve(&Resolvers.TradingAccount.list_trading_accounts/3)
    end
  end
end
