# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :kura,
  ecto_repos: [Kura.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :kura, KuraWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: KuraWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Kura.PubSub,
  live_view: [signing_salt: "LkjIT/PH"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :kura, Kura.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :kura, Kura.Guardian,
  issuer: "kura",
  secret_key: "fautE4a7EGRUHC2h74img9VQriNAs3ljueMmWM6IFbPgSST/U+crIDq1gxyBOHQ373o=",
  ttl: {3, :days}

config :kura, KuraWeb.AuthAccessPipeline,
  module: Kura.Guardian,
  error_handler: KuraWeb.AuthErrorHandler

config :kura, Kura.Mailer,
  adapter: Bamboo.MandrillAdapter,
  api_key: "my_api_key"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
