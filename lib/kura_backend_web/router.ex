defmodule KuraWeb.Router do
  use KuraWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_authenticated do
    plug KuraWeb.AuthAccessPipeline
    plug KuraWeb.Context
  end

  pipeline :graphql do
    plug KuraWeb.Context
  end

  scope "/api" do
    pipe_through :api_authenticated

    forward "/", Absinthe.Plug, schema: KuraWeb.Schema
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  if Mix.env() == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end

  if Mix.env() == :dev do
    forward "/graphiql", Absinthe.Plug.GraphiQL, schema: KuraWeb.Schema
  end
end
