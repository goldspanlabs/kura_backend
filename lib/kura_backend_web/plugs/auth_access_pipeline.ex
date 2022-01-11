defmodule KuraWeb.AuthAccessPipeline do
  use Guardian.Plug.Pipeline, otp_app: :kura

  plug Guardian.Plug.VerifyHeader, scheme: "Bearer"
  plug Guardian.Plug.LoadResource, allow_blank: true
end
