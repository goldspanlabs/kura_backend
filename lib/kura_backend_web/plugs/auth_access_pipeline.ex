defmodule KuraBackendWeb.AuthAccessPipeline do
  use Guardian.Plug.Pipeline, otp_app: :kura_backend

  plug Guardian.Plug.VerifyHeader, scheme: "Bearer"
  plug Guardian.Plug.LoadResource, allow_blank: true
end
