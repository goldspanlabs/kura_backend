defmodule KuraBackendWeb.Resolvers.Positions do
  def open_positions(_, _, %{context: %{current_user: current_user}}) do
    {:ok, KuraBackend.Positions.open_positions(current_user.id)}
  end

  def closed_positions(_, _, %{context: %{current_user: current_user}}) do
    {:ok, KuraBackend.Positions.closed_positions(current_user.id)}
  end
end
