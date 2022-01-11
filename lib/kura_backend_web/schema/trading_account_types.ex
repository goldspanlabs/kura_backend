defmodule KuraBackendWeb.Schema.TradingAccountTypes do
  use Absinthe.Schema.Notation

  alias KuraBackendWeb.Resolvers
  alias KuraBackendWeb.Schema.Middleware

  object :trading_account do
    field :id, non_null(:id)
    field :name, non_null(:string)
    field :currency, non_null(:string)
  end

  @desc "List trading accounts"
  object :trading_account_queries do
    field :trading_accounts, list_of(:trading_account) do
      middleware(Middleware.Authorize)
      resolve(&Resolvers.TradingAccount.list_trading_accounts/3)
    end
  end
end
