defmodule KuraBackend.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      KuraBackend.Repo,
      # Start the Telemetry supervisor
      KuraBackendWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: KuraBackend.PubSub},
      # Start the Endpoint (http/https)
      KuraBackendWeb.Endpoint
      # Start a worker by calling: KuraBackend.Worker.start_link(arg)
      # {KuraBackend.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: KuraBackend.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    KuraBackendWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
